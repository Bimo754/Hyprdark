import QtQuick
import Quickshell.Services.Mpris
import "../../../"

Row {
    id: mprisRoot
    anchors.centerIn: parent
    spacing: 10

    property var activePlayer: (Mpris.players.values && Mpris.players.values.length > 0) ? Mpris.players.values[0] : null
    property bool isPlaying: activePlayer ? activePlayer.playbackState === MprisPlaybackState.Playing : false
    property string trackTitle: activePlayer ? (activePlayer.trackTitle || "Media") : "Media"
    property string trackArtist: activePlayer ? (activePlayer.trackArtist || "") : ""

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: mprisRoot.isPlaying ? "󰎆" : "󰐎"
        font.family: StyleTokens.monoFontFamily
        font.pixelSize: 13
        color: StyleTokens.textSecondary
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: (mprisRoot.trackArtist ? (mprisRoot.trackArtist + " - ") : "") + mprisRoot.trackTitle
        font.family: StyleTokens.fontFamily
        font.pixelSize: 11
        font.weight: Font.Medium
        color: StyleTokens.textPrimary
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 140)
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Rectangle {
            width: 20
            height: 20
            radius: StyleTokens.capsuleRadius
            color: prevMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
            Text {
                anchors.centerIn: parent
                text: "󰒮"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 11
                color: StyleTokens.textPrimary
            }
            MouseArea {
                id: prevMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (mprisRoot.activePlayer) mprisRoot.activePlayer.previous()
            }
        }

        Rectangle {
            width: 20
            height: 20
            radius: StyleTokens.capsuleRadius
            color: ppMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
            Text {
                anchors.centerIn: parent
                text: mprisRoot.isPlaying ? "󰏤" : "󰐊"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 11
                color: StyleTokens.textPrimary
            }
            MouseArea {
                id: ppMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (mprisRoot.activePlayer) mprisRoot.activePlayer.togglePlaying()
            }
        }

        Rectangle {
            width: 20
            height: 20
            radius: StyleTokens.capsuleRadius
            color: nextMouse.containsMouse ? StyleTokens.surfaceHover : StyleTokens.transparent
            Text {
                anchors.centerIn: parent
                text: "󰒭"
                font.family: StyleTokens.monoFontFamily
                font.pixelSize: 11
                color: StyleTokens.textPrimary
            }
            MouseArea {
                id: nextMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (mprisRoot.activePlayer) mprisRoot.activePlayer.next()
            }
        }
    }
}
