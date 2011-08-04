import QtQuick 1.1
import org.kde.qtextracomponents 0.1
import com.nokia.meego 1.0

Window {

    id: root
    Component.onCompleted: {
        theme.inverted = true
        screen.allowedOrientations = Screen.Landscape | Screen.LandscapeInverted
    }

    Rectangle {
        id: content
        anchors.top: parent.top
        anchors.bottom: toolBar.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "black"
        Item {
            id: openArea
            objectName: "openArea"
            height: 100
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: locationText.bottom
            opacity: 0.1
            Rectangle {
                anchors.fill: parent
                color: "#000033"
                border.width: 10
                border.color: "#030064"
                radius: 10
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "open"
                    font.pixelSize: parent.height
                    color: "#ffffff"

                }
            }
        }

        Item {
            id: selectionArea
            objectName: "selectionArea"
            y: 381
            height: 100
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            opacity: 0.1
            Rectangle {
                anchors.fill: parent
                color: "#000033"
                border.width: 10
                border.color: "#030064"
                radius: 10
                Text {
                    color: "#ffffff"
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "selection"
                    font.pixelSize: parent.height
                }
            }
        }

        Component {
            id: fileDelegate

            Item {
                id: modelItem
                width: 64; height: 80
                property bool dragging: false
                property int dragStart
                y: fileView.height/2 -40
                state: (coreObject.fileIsSelected(viewModel.modelIndex(index)) ?
                            "selected"
                          : "")
                states: [
                    State {
                        name: "selected"
                        PropertyChanges {
                            target: modelItem
                            y: fileView.height/2 + 100

                        }
                    },
                    State {
                        name: ""
                        PropertyChanges {
                            target: modelItem
                            y: fileView.height/2 -40
                        }
                    }
                ]

                QIconItem {
                    id: myIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 48
                    height: 48
                    icon: fileIcon
                }

                Text {
                    anchors { top: myIcon.bottom; horizontalCenter: parent.horizontalCenter }
                    width: modelItem.width
                    text: fileName
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: modelItem
                    drag.axis: "YAxis"
                    drag.minimumY: 0
                    drag.maximumY: content.height - modelItem.height
                    drag.onActiveChanged: {
                        if (drag.active) {
                            showAreas.start()
                            modelItem.dragging = true
                        } else {
                            hideAreas.start()
                            modelItem.dragging = false
                        }
                    }
                }
                onDraggingChanged: {
                    if (!dragging) {
                        var stateChange = coreObject.stateChange(modelItem)
                        if (stateChange == 1) {
                            coreObject.openFile(viewModel.modelIndex(index))
                            y = fileView.height/2 -40
                        } else if (stateChange == 2) {
                            coreObject.fileSelected(viewModel.modelIndex(index) , true)
                            if (state == "selected")
                                y = fileView.height/2 + 100
                            else
                                state = "selected"
                        } else {
                            coreObject.fileSelected(viewModel.modelIndex(index) , false)
                            if (state == "")
                                y = fileView.height/2 -40
                            else
                                state = ""
                        }
                    }
                }
            }
        }

        VisualDataModel {
            id: viewModel
            objectName: "viewModel"
            delegate: fileDelegate
            model: fileSystemModel
        }

        ListView {
            orientation: ListView.Horizontal
            anchors.top: locationText.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            id: fileView
            objectName: "fileViewObj"
            model: viewModel
            interactive: true
            focus: true

            Keys.onPressed: {
                if (event.key == Qt.Key_Backspace) {
                    coreObject.openFile(model.parentModelIndex())
                    event.accepted = true
                }
            }

        }

        TextField {
            id: locationText
            objectName: "locationText"
            text: coreObject.currentPath
            anchors.right: content.right
            anchors.left: content.left
            anchors.top: content.top
            height: 40
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            width: parent.width
            platformSipAttributes:  SipAttributes {
                actionKeyLabel: "Go to"
                actionKeyHighlighted: true
                actionKeyEnabled: true
            }
            Keys.onReturnPressed: {
                fileView.forceActiveFocus()
                coreObject.openPath(text)
            }
        }
        PropertyAnimation {
            id: showAreas
            targets: [openArea, selectionArea]
            property: "opacity"
            to: 1
        }
        PropertyAnimation {
            id: hideAreas
            targets: [openArea, selectionArea]
            property: "opacity"
            to: 0.1
        }
    }
    ToolBar {
        id: toolBar
        anchors.bottom: parent.bottom
        privateVisibility: (inputContext.softwareInputPanelVisible==true || inputContext.customSoftwareInputPanelVisible == true)
                           ? ToolBarVisibility.HiddenImmediately : ToolBarVisibility.Visible
        tools: ToolBarLayout {
            ToolButtonRow {

                ToolIcon {
                    iconSource: "icon-m-toolbar-cut".concat(theme.inverted ? "-white" : "");
                    onClicked: coreObject.invokeAction(1);
                    enabled: coreObject.filesSelected
                    opacity: enabled ? 1.0 : 0.3
                }
                ToolIcon {
                    iconSource: "icon-m-toolbar-copy".concat(theme.inverted ? "-white" : "");
                    onClicked: coreObject.invokeAction(2);
                    enabled: coreObject.filesSelected
                    opacity: enabled ? 1.0 : 0.3
                }
                ToolIcon {
                    iconSource: "icon-m-toolbar-paste".concat(theme.inverted ? "-white" : "");
                    onClicked: coreObject.invokeAction(3);
                    enabled: coreObject.filesInClipboard
                    opacity: enabled ? 1.0 : 0.3
                }
                ToolIcon {
                    iconSource: "icon-m-toolbar-delete".concat(theme.inverted ? "-white" : "");
                    onClicked: deleteDialog.open()
                    enabled: coreObject.filesSelected
                    opacity: enabled ? 1.0 : 0.3
                }
                ToolIcon {
                    iconSource: "icon-m-toolbar-share".concat(theme.inverted ? "-white" : "");
                    onClicked: coreObject.invokeAction(5);
                    enabled: coreObject.filesSelected
                    opacity: enabled ? 1.0 : 0.3
                }
                ToolIcon {
                    iconId: "toolbar-back";
                    onClicked: coreObject.openFile(viewModel.parentModelIndex())
                }
                ToolIcon {
                    iconId: "toolbar-tools";
                    onClicked: settingsDialog.open()
                }
            }

        }
    }

    QueryDialog {
        id: deleteDialog
        titleText:  "Are you sure?"
        message: "You are about to delete files."
        acceptButtonText: "Yes"
        rejectButtonText: "No"
        onAccepted: coreObject.invokeAction(4); // invoke delete
        visualParent: root
    }

    Sheet {
        id: settingsDialog
        title: Label { anchors.top: parent.top; anchors.topMargin: 16; anchors.horizontalCenter: parent.horizontalCenter; text: "CuteExplorer"}
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"
        content: Flickable {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.topMargin: 10
            contentWidth: col2.width
            contentHeight: col2.height
            flickableDirection: Flickable.VerticalFlick
            Column {
                id: col2
                anchors.top: parent.top
                spacing: 20
                Row {
                    spacing: 20
                    Label {
                        anchors.verticalCenter: sShowHidden.verticalCenter
                        id:lShowHidden
                        text: "Show Hidden"
                    }
                    Switch {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        id: sShowHidden
                        checked: coreObject.showHidden
                    }
                }
            }
        }
        visualParent: root
        onAccepted:
            coreObject.showHidden = sShowHidden.checked
        onRejected: sShowHidden.checked = coreObject.showHidden
    }
}
