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
        opacity: 0

        Rectangle {
            anchors.fill: parent
            color: "#000033"
            border.width: 10
            border.color: "#030064"
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
        opacity: 0
        Rectangle {
            anchors.fill: parent
            color: "#000033"
            border.width: 10
            border.color: "#030064"
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
            anchors.verticalCenterOffset: coreObject.fileIsSelected(viewModel.modelIndex(index)) ?
                   100
                 : 0
            onDraggingChanged: {
                if (!dragging) {
                    var stateChange = coreObject.stateChange(modelItem)
                    if (stateChange == 1) {
                        anchors.verticalCenterOffset = -100
                        coreObject.openFile(viewModel.modelIndex(index))
                    } else if (stateChange == 2) {
                        anchors.verticalCenterOffset = 100
                        coreObject.fileSelected(viewModel.modelIndex(index) , true)
                    } else {
                        anchors.verticalCenterOffset = 0
                        coreObject.fileSelected(viewModel.modelIndex(index) , false)
                    }
                }
            }
            states: [
                State {
                    name: "selected"
                    PropertyChanges {
                        target: modelItem
                        y: yZero + 50
                    }
                },
                State {
                    name: ""
                    PropertyChanges {
                        target: modelItem
                        y: yZero
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
        }
    }
    
    VisualDataModel {
        id: viewModel
        objectName: "viewModel"
        delegate: fileDelegate
        model: fileSystemModel
    }

    PathView {

        anchors.top: locationText.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        id: fileView
        objectName: "fileViewObj"
        dragMargin: height
        model: viewModel
        interactive: true
        focus: true
        path: Path {
            startX: 32
            startY: root.height/2
            PathLine { x: root.width-32; y: root.height/2 }

        }
        pathItemCount: root.width/80


        Keys.onPressed: {
            if (event.key == Qt.Key_Backspace) {
                model.rootIndex = model.parentModelIndex()
                event.accepted = true
            }
        }
    }
    
    TextInput {
        id: locationText
        text: ""
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
        to: 0
    }
}
