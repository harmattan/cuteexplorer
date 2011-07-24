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
                            modelItem.dragStart = y
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
                            y = dragStart
                        } else if (stateChange == 2) {
                            coreObject.fileSelected(viewModel.modelIndex(index) , true)
                            if (state == "selected")
                                y = dragStart
                            else
                                state = "selected"
                        } else {
                            coreObject.fileSelected(viewModel.modelIndex(index) , false)
                            if (state == "")
                                y = dragStart
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
            text: ""
            //            color: "#FFFFFF"
            anchors.right: content.right
            anchors.left: content.left
            anchors.top: content.top
            height: 40
            width: parent.width
            //            font.pixelSize: 20
            //            onAccepted: {
            //                locationText.focus = false
            //                fileView.focus = true
            //                coreObject.openPath(text)
            //            }
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
//                    visible: false
                }
                ToolIcon {
                    iconSource: "icon-m-toolbar-copy".concat(theme.inverted ? "-white" : "");
                    onClicked: coreObject.invokeAction(2);
//                    visible: false
                }
                ToolIcon {
                    iconSource: "icon-m-toolbar-paste".concat(theme.inverted ? "-white" : "");
                    onClicked: coreObject.invokeAction(3);
//                    visible: false
                }
                ToolIcon {
                    iconSource: "icon-m-toolbar-delete".concat(theme.inverted ? "-white" : "");
                    onClicked: deleteDialog.open()


//                    visible: false
                }
                ToolIcon {
                    iconSource: "icon-m-toolbar-share".concat(theme.inverted ? "-white" : "");
                    onClicked: coreObject.invokeAction(5);
//                    visible: false
                }
                ToolIcon {
                    iconId: "toolbar-back";
                    onClicked: coreObject.openFile(viewModel.parentModelIndex())
                }
            }

        }

    }

    Dialog {
        id: deleteDialog
        title:
            Label {text:"Are you sure?"}
        content: Label { text:"You are about to delete files." }
        buttons: ButtonRow {
            Button {
                id: yesButton
                text: "Yes"
                onClicked: deleteDialog.accept()
            }
            Button {
                id: noButton
                text: "No"
                onClicked: deleteDialog.reject()
            }
        }
        onAccepted: coreObject.invokeAction(4); // invoke delete
        onStatusChanged:
            if (status == DialogStatus.Open) {
                noButton.pressed = false
                yesButton.pressed = false
            }
    }
}
