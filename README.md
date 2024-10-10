<!--
SPDX-FileCopyrightText: 2023-2024 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# DragDrop

QML module for ordering lists by drag-and-drop in Sailfish apps

This module enables ordering lists by drag-and-drop with just a few lines of
code. Using this module saves you from writing a couple hundred lines of
specialized code for each view that should support drag-and-drop.


## Usage

This module can be used with any custom view. It requires a model that supports
moving elements.

Basic usage with `Opal.Delegates` takes only five lines of code:

```{qml}
import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.Delegates 1.0
import Opal.DragDrop 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    ListModel {
        id: myModel
        ListElement { name: "Jane" }
        ListElement { name: "John" }
        ListElement { name: "Judy" }
    }

    SilicaListView {
        id: view
        model: myModel
        anchors.fill: parent
        header: PageHeader { title: "People" }
        VerticalScrollDecorator {}

        ViewDragHandler {
            id: viewDragHandler
            listView: view
        }

        delegate: OneLineDelegate {
            text: name
            dragHandler: viewDragHandler
        }
    }
}
```


Basic usage with a custom list delegate takes more code because you have to
add the visual `DragHandle` manually and take care of styling. The drag-and-drop
integration still takes less than 15 lines of code:

```
import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.Delegates 1.0
import Opal.DragDrop 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    ListModel {
        id: myModel
        ListElement { name: "Jane" }
        ListElement { name: "John" }
        ListElement { name: "Judy" }
    }

    SilicaListView {
        id: view
        model: myModel
        anchors.fill: parent
        header: PageHeader { title: "People" }
        VerticalScrollDecorator {}

        ViewDragHandler {
            id: viewDragHandler
            listView: view
        }

        delegate: ListItem {
            id: delegate
            contentHeight: Theme.itemSizeSmall

            Label {
                text: name
                truncationMode: TruncationMode.Fade
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: handle.left
                    rightMargin: Theme.paddingMedium
                }
            }

            // Create a visual handle to grab the item, and connect
            // it to the drag handler of the view and the drag handler
            // of the delegate.
            //
            // This part is already taken care of when using Opal.Delegates.
            DragHandle {
                id: handle

                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }

                // The delegate needs its own drag handler that is
                // connected to the outer drag handler of the view.
                // The delegate drag handler must know the index
                // of the delegate.
                moveHandler: DelegateDragHandler {
                    viewHandler: viewDragHandler
                    handledItem: delegate
                    modelIndex: index
                }
            }
        }
    }
}
```

## Screenshots

Screenshots can be found in the [doc](doc/) directory.

## How to use

You do not need to clone this repository if you only intend to use the module in
another project. Simply download the latest release bundle from the "Releases" page.

### Setup

Follow the main documentation for installing Opal modules
[here](https://github.com/Pretty-SFOS/opal/blob/main/README.md#using-opal).

### Configuration

See [`doc/gallery.qml`](doc/gallery.qml) for an example. Read the file to get
started.

### Documentation

Documentation is included in the release bundle and can be added to
QtCreator via Extras → Settings → Help → Documentation → Add.

## Translations

To **use** packaged translations in your project, follow the main documentation for
using Opal modules [here](https://github.com/Pretty-SFOS/opal#using-opal).

You can also **contribute** translations. If an app uses Opal modules, consider
updating its translations at the source (i.e. here), so that all Opal users can
benefit from it. Translations are managed using
[Weblate](https://hosted.weblate.org/projects/opal).

Please prefer Weblate over pull requests (which are still welcome, of course).
If you just found a minor problem, you can also
[leave a comment in the forum](https://forum.sailfishos.org/t/opal-qml-components-for-app-development/15801)
or [open an issue](https://github.com/Pretty-SFOS/opal/issues/new).

Please include the following details:

1. the language you were using
2. where you found the error
3. the incorrect text
4. the correct translation

See [the Qt documentation](https://doc.qt.io/qt-5/qml-qtqml-date.html#details) for
details on how to translate date formats to your local format.

## License

    Copyright (C)  Mirian Margiani
    Program: opal-dragdrop

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
