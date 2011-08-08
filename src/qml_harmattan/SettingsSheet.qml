import QtQuick 1.0
import com.nokia.meego 1.0

Sheet {
    id: settingsDialog
    title: Label { anchors.top: parent.top; anchors.topMargin: 16; anchors.horizontalCenter: parent.horizontalCenter; text: "CuteExplorer Settings"}
    acceptButtonText: "Ok"
    rejectButtonText: "Cancel"
    content: Flickable {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.topMargin: 10
        contentWidth: col.width
        contentHeight: col.height
        flickableDirection: Flickable.VerticalFlick
        Column {
            id: col
            anchors.top: parent.top
            spacing: 20
            Row {
                spacing: 20
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    id:lShowHidden
                    text: "Show Hidden"
                }
                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    id: sShowHidden
                    checked: coreObject.showHidden
                }
            }
        }
    }

    onAccepted: {
        coreObject.showHidden = sShowHidden.checked
    }
}
