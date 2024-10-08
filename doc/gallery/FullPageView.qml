//@ This file is part of opal-dragdrop.
//@ https://github.com/Pretty-SFOS/opal-dragdrop
//@ SPDX-FileCopyrightText: 2024 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.0
import Sailfish.Silica 1.0 as S
import Opal.Delegates 1.0 as D
import Opal.MenuSwitch 1.0 as M
import Opal.DragDrop 1.0
import ".."

S.Page {
    id: root
    allowedOrientations: S.Orientation.All

    property bool dragMode: true

    S.SilicaListView {
        id: view
        anchors.fill: parent
        model: LongFruitModel {}

        S.VerticalScrollDecorator {
            flickable: view
        }

        header: S.PageHeader {
            title: "Opal.DragDrop"
        }

        footer: Item {
            width: parent.width
            height: S.Theme.horizontalPageMargin
        }

        S.PullDownMenu {
            M.MenuSwitch {
                text: qsTranslate("DragDrop", "Enable drag and drop")
                checked: dragMode
                automaticCheck: false
                onClicked: dragMode = !dragMode
            }
        }

        // Create a drag handler for the SilicaListView.
        ViewDragHandler {
            id: viewDragHandler
            listView: parent
            active: dragMode

            // Setting the flickable explicitly is not necessary here,
            // because the SilicaListView itself is the main flickable on
            // this page.
            // --- flickable: view
        }

        delegate: D.OneLineDelegate {
            text: name
            interactive: false

            // Register the drag handler in the delegate.
            dragHandler: viewDragHandler

            leftItem: D.DelegateIconItem {
                source: "image://theme/icon-m-favorite"
            }
            rightItem: D.DelegateInfoItem {
                text: price
                description: qsTranslate("Delegates", "per kg")
                alignment: Qt.AlignRight
            }
        }
    }
}
