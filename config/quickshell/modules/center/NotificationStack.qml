import QtQuick
import Quickshell
import "../.."

Item {
    id: notiStackRoot
    anchors.fill: parent

    property var liveCards: ({})

    Component {
        id: cardComponent
        NotificationCard {}
    }

    Item {
        id: cardsContainer
        anchors.fill: parent
    }

    function syncCards() {
        let list = NotificationState.activeList;
        let activeIds = {};

        for (let i = 0; i < list.length; i++) {
            let item = list[i];
            if (!item) continue;
            activeIds[item.id] = true;

            if (!liveCards[item.id]) {
                // Spawn new card instance with initial pop-in transform
                let newCard = cardComponent.createObject(cardsContainer, {
                    notiId: item.id,
                    targetSlot: i,
                    y: -24,
                    opacity: 0.0,
                    scale: 0.90
                });
                newCard.updateData(item);
                // Trigger entry transition in next cycle
                newCard.targetSlot = i;
                newCard.opacity = 1.0;
                newCard.scale = 1.0;
                newCard.y = i * 60;
                liveCards[item.id] = newCard;
            } else {
                let card = liveCards[item.id];
                card.targetSlot = i;
                card.updateData(item);
                if (item.isEvicting) {
                    card.y = Math.max(0, (i - 1) * 60);
                    card.opacity = 0.0;
                    card.scale = 0.90;
                } else {
                    card.y = i * 60;
                    card.opacity = 1.0;
                    card.scale = 1.0;
                }
            }
        }

        // Clean up cards no longer in activeList
        let keys = Object.keys(liveCards);
        for (let k = 0; k < keys.length; k++) {
            let id = keys[k];
            if (!activeIds[id]) {
                if (liveCards[id]) {
                    liveCards[id].exitAndDestroy();
                }
                delete liveCards[id];
            }
        }
    }

    Connections {
        target: NotificationState
        function onActiveListChanged() {
            notiStackRoot.syncCards();
        }
    }

    Component.onCompleted: {
        syncCards();
    }
}
