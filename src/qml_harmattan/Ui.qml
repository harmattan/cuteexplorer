import QtQuick 1.1

import com.nokia.meego 1.0
import "." 1.0

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



        VisualDataModel {
            id: viewModel
            objectName: "viewModel"
            delegate: Component {
                FileDelegate {
                    lineCenter: fileView.height/2 -40
                    lineSelected: fileView.height/2 + 100
                    onDragStart: showAreas.start()
                    onDragStop: hideAreas.start()
                }
            }
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
                Item {} // aligns to right?
                ToolIcon {
                    iconId: "toolbar-add"
                    onClicked: coreObject.newFileFolder();
//                    enabled:
                    opacity: enabled ? 1.0 : 0.3
                }
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
                    onClicked: settingsSheet.open()
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
    SettingsSheet {
        id: settingsSheet
    }
}
