//@ This file is part of opal-dragdrop.
//@ https://github.com/Pretty-SFOS/opal-dragdrop
//@ SPDX-FileCopyrightText: 2024 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    id: root

    // Important: the type of this property must be QtObject
    // instead of ViewDragHandler, even though only a ViewDragHandler
    // object is acceptable here. Using the simpler type is
    // necessary to allow mixing objects created through importing
    // the module via its path and via the dot notation. QML treats
    // those objects as different types even though they are the same.
    property QtObject /*ViewDragHandler*/ viewHandler

    property Item handledItem
    property int modelIndex: -1

    // public
    readonly property bool active: !!viewHandler && viewHandler.active
    readonly property bool dragging: !!viewHandler && viewHandler.active ?
        viewHandler._dragItem === handledItem : false

    // internal
    property alias _draggableItem: _draggableItem
    property double _previousOpacity: 1.0

    readonly property var _listView: viewHandler.listView
    readonly property var _flickable: viewHandler.flickable

    function _findTargetIndex() {
        var finalIndex = -1
        var itemY = _draggableItem.y

        if (_listView === _flickable) {
            itemY = _draggableItem.mapToItem(_listView.contentItem, 0, 0).y
        }

        if (itemY < 0) {
            finalIndex = 0
        } else if (itemY + _draggableItem.height / 2 >
                   _listView.contentHeight) {
            finalIndex = _listView.indexAt(_listView.contentX,
                                           _listView.contentHeight - 1)
        } else {
            finalIndex = _listView.indexAt(
                _listView.contentX,
                itemY + _draggableItem.height / 2)
        }

        return finalIndex
    }

    function _startDrag() {
        if (!viewHandler) {
            console.error("[DelegateDragHandler] viewHandler must not be null, set it to a valid value")
            return
        } else if (!viewHandler.hasOwnProperty('__opal_view_drag_handler')) {
            console.error("[DelegateDragHandler] viewHandler must be a reference to a valid ViewDragHandler")
            return
        }

        _previousOpacity = handledItem.opacity
        _draggableItem.source = ''

        handledItem.grabToImage(function(result) {
            _draggableItem.source = result.url
            viewHandler._draggedItem = _draggableItem
            viewHandler._dragItem = handledItem
            viewHandler._dragIndex = modelIndex
        }, Qt.size(handledItem.width,
                   handledItem.height))
    }

    function _stopDrag() {
        if (dragging) {
            var finalIndex = _findTargetIndex()

            if (finalIndex >= 0) {
                if (finalIndex !== modelIndex) {
                    viewHandler.itemMoved(handledItem, modelIndex, finalIndex)
                }

                if (finalIndex !== viewHandler._dragIndex) {
                    viewHandler.itemDropped(handledItem, viewHandler._dragIndex, modelIndex, finalIndex)
                }
            }

            console.log("stopped at", finalIndex,
                        "| moved from", viewHandler._dragIndex,
                        "via", modelIndex, "to", finalIndex)

            handledItem.opacity = _previousOpacity
            viewHandler._draggedItem = null
            viewHandler._dragItem = null
            viewHandler._dragIndex = -1
            _draggableItem.source = ''
        }
    }

    function handleScrolling() {
        if (root.dragging) {
            var mappedY = _draggableItem.mapToItem(_flickable, 0, 0).y

            if (mappedY - _draggableItem.height < 0 &&
                _flickable.contentY > viewHandler._minimumFlickableY) {
                viewHandler._scrollUp()
            } else if (_flickable.contentY < viewHandler._maximumFlickableY &&
                       mappedY + _draggableItem.height * 3 / 2 > _flickable.height) {
                viewHandler._scrollDown()
            } else {
                viewHandler._stopScrolling()

                var i = _findTargetIndex()
                if (i >= 0 && i !== root.modelIndex) {
                    console.log("MOVE", root.modelIndex, "TO", i)
                    viewHandler.itemMoved(handledItem, modelIndex, i)
                }
            }
        }
    }

    ListView.onRemove: {
        animateRemoval(handledItem)
    }

    Binding {
        when: dragging
        target: handledItem
        property: "opacity"
        value: 0.0
    }

    Image {
        id: _draggableItem
        anchors.horizontalCenter: parent.horizontalCenter
        width: handledItem.width
        height: handledItem.height
        visible: !!source.toString()
        onYChanged: handleScrolling()

//        Connections {
//            target: root.dragging ? _flickable : null
//            onContentYChanged: handleScrolling()
//        }

        Rectangle {
            z: -100
            visible: _draggableItem.visible
            anchors.fill: parent
            color: Theme.highlightBackgroundColor
            opacity: Theme.highlightBackgroundOpacity
        }

        states: [
            State {
                name: "normal"
                when: !root.dragging
                ParentChange {
                    target: _draggableItem
                    parent: handledItem.contentItem
                    rotation: 0
                    y: 0
                }
            },
            State {
                name: "dragging"
                when: root.dragging
                ParentChange {
                    target: _draggableItem
                    parent: _listView
                    rotation: 0
                    y: _draggableItem.mapToItem(_listView, 0, 0).y
                }
            }
        ]
    }
}
