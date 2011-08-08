import QtQuick 1.0
import org.kde.qtextracomponents 0.1

Item {
    property real lineCenter
    property real lineSelected
    signal dragStart
    signal dragStop
    id: modelItem
    width: 64; height: 80
    y: modelItem.lineCenter
    state: (coreObject.fileIsSelected(viewModel.modelIndex(index)) ?
                "selected"
              : "")
    states: [
        State {
            name: "selected"
            PropertyChanges {
                target: modelItem
                y: modelItem.lineSelected

            }
        },
        State {
            name: ""
            PropertyChanges {
                target: modelItem
                y: modelItem.lineCenter
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
                modelItem.dragStart()
            } else {
                modelItem.dragStop()
                var stateChange = coreObject.stateChange(modelItem)
                if (stateChange == 1) {
                    coreObject.openFile(viewModel.modelIndex(index))
                    modelItem.y = modelItem.lineCenter
                } else if (stateChange == 2) {
                    coreObject.fileSelected(viewModel.modelIndex(index) , true)
                    if (modelItem.state == "selected")
                        modelItem.y = modelItem.lineSelected
                    else
                        modelItem.state = "selected"
                } else {
                    coreObject.fileSelected(viewModel.modelIndex(index) , false)
                    if (modelItem.state == "")
                        modelItem.y = modelItem.lineCenter
                    else
                        modelItem.state = ""
                }
            }
        }
    }
}
