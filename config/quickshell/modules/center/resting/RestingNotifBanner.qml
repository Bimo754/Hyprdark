import QtQuick
import "../../../"

Row {
    id: notifBannerRoot
    anchors.centerIn: parent
    spacing: 8

    property string appName: "Notification"
    property string title: ""
    property string body: ""

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "󰂚"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 13
        color: StyleTokens.textSecondary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: notifBannerRoot.appName + (notifBannerRoot.title ? (": " + notifBannerRoot.title) : "")
        font.family: StyleTokens.fontFamily
        font.pixelSize: 11
        font.weight: Font.Medium
        color: StyleTokens.textPrimary
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 240)
    }
}
