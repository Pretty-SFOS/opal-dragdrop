//@ This file is part of opal-dragdrop.
//@ https://github.com/Pretty-SFOS/opal-dragdrop
//@ SPDX-FileCopyrightText: 2024 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.6
import Sailfish.Silica 1.0

/*!
    \qmltype ViewDragHandler
    \inqmlmodule Opal.DragDrop
    \inherits QtObject
    \brief A configurable scroll bar for random access in long list views.

    This module can be used instead of Silica's \c VerticalScrollDecorator.
    It provides an interface for Silica's private scrollbar and falls back
    to the standard \c VerticalScrollDecorator if the private API is not
    available.

    The scrollbar can show two lines of information, and most importantly,
    it allows scrolling to any position in the list view. The
    default \c VerticalScrollDecorator only allows scrolling quickly to
    the top or the bottom.

    \section2 Example

    \qml
    import QtQuick 2.0
    import Sailfish.Silica 1.0
    import Opal.SmartScrollbar 1.0

    Page {
        id: root
        allowedOrientations: Orientation.All

        SilicaListView {
            id: flick
            anchors.fill: parent

            SmartScrollbar {
                flickable: flick
                text: "..."
            }

            model: [1, 2, 3]

            delegate: ListItem {
                contentHeight: Theme.itemSizeSmall

                Label {
                    width: parent.width - 2*x
                    x: Theme.horizontalPageMargin
                    text: modelData
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
    \endqml

    \section2 Accessing list elements

    Use this code to show the current index and data of the current
    list element in your scrollbar:

    \qml
    SmartScrollbar {
        flickable: myFlickable

        readonly property var scrollItem: !!flickable ?
            flickable.itemAt(flickable.contentX, flickable.contentY) : null
        readonly property int scrollIndex: !!flickable ?
            flickable.indexAt(flickable.contentX, flickable.contentY) : -1

        text: "%1 / %2".arg(scrollIndex + 2).arg(flickable.count)
        description: !!scrollItem ? scrollItem.myProperty : ""
    }
    \endqml

    However, remember that the \c scrollItem and \c scrollIndex
    properties incur a performance cost that can make scrolling feel
    slow, sluggish or erratic. This depends on your list.
*/
Item {
    id: root

    // public API
    property Item /*ListView*/ listView
    property QtObject smartScrollbar  // optional
    property bool active: !!listView
    property bool handleMove: true
    property Flickable flickable: !!listView ? listView : null

    // internal API
    property Item _draggedItem
    property int _originalIndex: -1
    readonly property bool _scrolling: scrollUpTimer.running || scrollDownTimer.running

    readonly property int _minimumFlickableY: {
        if (!flickable || !listView || !_draggedItem) return 0

        if (flickable === listView) {
            return !!listView.headerItem ? -listView.headerItem.height : 0
        } else {
            var base = flickable.contentY + listView.mapToItem(flickable, 0, 0).y
            return base - _draggedItem.height * 3 / 2
        }
    }
    readonly property int _maximumFlickableY: {
        if (!flickable || !listView || !_draggedItem) return 0

        if (flickable === listView) {
            return   listView.contentHeight
                   - listView.height
                   - (!!listView.headerItem ? listView.headerItem.height : 0)
        } else {
            var base =   flickable.contentY
                       + listView.mapToItem(flickable, 0, 0).y
                       + listView.height
                       - flickable.height
            return Math.min(
                base + _draggedItem.height /** 3 / 2*/,
                flickable.contentHeight)
        }
    }

    // internal
    // used to identify an object as a valid view drag handler
    readonly property bool __opal_view_drag_handler: true

    // public
    signal itemMoved(var fromIndex, var toIndex)
    signal itemDropped(var originalIndex, var currentIndex, var finalIndex)

    function _scrollUp() {
        scrollUpTimer.start()
        scrollDownTimer.stop()
    }

    function _scrollDown() {
        scrollUpTimer.stop()
        scrollDownTimer.start()
    }

    function _stopScrolling() {
        scrollUpTimer.stop()
        scrollDownTimer.stop()
    }

    function _setListViewProperties() {
        if (!listView) return
        listView.moveDisplaced = moveDisplaced
    }

    onItemMoved: {
        if (!handleMove) return
        listView.model.move(fromIndex, toIndex, 1)
    }

    onListViewChanged: {
        _setListViewProperties()
    }

    implicitWidth: 0
    implicitHeight: 0

    Binding {
        target: smartScrollbar
        property: "smartWhen"
        value: false
        when: !!flickable && root.active
    }

    Transition {
        id: moveDisplaced

        NumberAnimation {
            properties: "x,y"
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Timer {
        id: scrollUpTimer
        repeat: true
        interval: 10
        onTriggered: {
            if (!_draggedItem) {
                stop()
                return
            }

            if (flickable.contentY > _minimumFlickableY) {
                flickable.contentY -= 15
                // _draggedItem.y -= 5
            } else {
                stop()
                // flickable.contentY = 0
                // _draggedItem.y = 0
            }
        }
    }

    Timer {
        id: scrollDownTimer
        repeat: true
        interval: 10
        onTriggered: {
            if (!_draggedItem) {
                stop()
                return
            }

            if (flickable.contentY < _maximumFlickableY) {
                flickable.contentY += 15
                // _draggedItem.y += 5
            } else {
                stop()
                // flickable.contentY = _maximumFlickableY
                // _draggedItem.y = _maximumFlickableY
            }
        }
    }

    Component.onCompleted: {
        _setListViewProperties()
    }
}
