//@ This file is part of opal-dragdrop.
//@ https://github.com/Pretty-SFOS/opal-dragdrop
//@ SPDX-FileCopyrightText: 2024 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    x: Theme.horizontalPageMargin
    width: parent.width - 2*x
    wrapMode: Text.Wrap
    color: Theme.secondaryHighlightColor
    font.pixelSize: Theme.fontSizeSmall
}
