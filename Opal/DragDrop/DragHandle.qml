//@ This file is part of opal-dragdrop.
//@ https://github.com/Pretty-SFOS/opal-dragdrop
//@ SPDX-FileCopyrightText: 2024 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.6
import Sailfish.Silica 1.0

SilicaItem {
    id: root

    property DelegateDragHandler moveHandler
    property alias handleImage: image
    property bool showActiveArea: false // for debugging

    visible: !!moveHandler && moveHandler.active
    implicitWidth: visible ? Theme.itemSizeMedium : 0
    implicitHeight: visible ? Theme.itemSizeSmall - 2*Theme.paddingMedium : 0
    anchors.verticalCenter: parent.verticalCenter

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: root.visible

        onPressed: moveHandler._startDrag()
        onReleased: moveHandler._stopDrag()
        onCanceled: moveHandler._stopDrag()

        drag.target: !!moveHandler ?
            (moveHandler.dragging ? moveHandler._draggableItem : null) : null
        drag.axis: Drag.YAxis
    }

    HighlightImage {
        id: image
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        source: Qt.resolvedUrl("private/icons/drag-handle.png")
        width: Theme.iconSizeMedium
        height: width
        highlighted: root.highlighted || moveHandler.dragging || area.containsPress
    }

    // vvv DEBUG
    Rectangle {
        visible: showActiveArea
        anchors.fill: parent
        color: "red"
        opacity: 0.3
    }
    // ^^^ DEBUG
}
