import QtQuick 1.0
import org.kde.qtextracomponents 0.1


Rectangle {
    id: root
    color: "#000000"
    anchors.fill: parent
    width: 856
    height: 480
    Item {
        id: openArea
        objectName: "openArea"
        height: 150
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
        height: 150
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
            y: fileView.height/2 -40
            state: (coreObject.fileIsSelected(viewModel.modelIndex(index)) ?
                        "selected"
                      : "")
            states: [
                State {
                    name: "selected"
                    PropertyChanges {
                        target: modelItem
                        y: fileView.height/2 + 120

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
                drag.maximumY: root.height - modelItem.height
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
                    } else if (stateChange == 2) {
                        coreObject.fileSelected(viewModel.modelIndex(index) , true)
                    } else {
                        coreObject.fileSelected(viewModel.modelIndex(index) , false)
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
        //dragMargin: height
        model: viewModel
        interactive: true
        focus: true
//        path: Path {
//            startX: 32
//            startY: root.height/2
//            PathLine { x: root.width-32; y: root.height/2 }

//        }
//        pathItemCount: root.width/80


        Keys.onPressed: {
            if (event.key == Qt.Key_Backspace) {
                coreObject.openFile(model.parentModelIndex())
                event.accepted = true
            }
        }
    }
    
    TextInput {
        id: locationText
        objectName: "locationText"
        text: ""
        anchors.rightMargin: 71
        color: "#FFFFFF"
        selectByMouse: false
        anchors.right: root.right
        anchors.left: root.left
        anchors.top: root.top
        height: 20
        width: parent.width
        font.pixelSize: 18
        onAccepted: {
            locationText.focus = false
            fileView.focus = true
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

    Item {
        id: backButton
        height: 20
        anchors.right: parent.right
        anchors.left: locationText.right
        anchors.top: parent.top
        QIconItem {
            icon: coreObject.iconFromTheme("go-previous")
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked:
                coreObject.openFile(viewModel.parentModelIndex())
        }
    }
}
