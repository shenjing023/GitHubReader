import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    property string language;
    property string url;
    property string count;
    id:root;
    width: parent.width
    height: 30

    Label{
        id:lab1;
        height: parent.height
        text: language
        font{
            family: "Microsoft YaHei"
            pixelSize: 14
        }
        color: "gray"
        verticalAlignment: Text.AlignVCenter
        leftPadding: 5
    }

    Label{
        id:lab2;
        anchors.right: parent.right
        height: parent.height
        text: count
        font{
            family: "Microsoft YaHei"
            pixelSize: 14
        }
        color: "gray"
        verticalAlignment: Text.AlignVCenter
        rightPadding: 5
    }

    MouseArea{
        anchors.fill: parent;
        hoverEnabled: true;
        cursorShape:Qt.PointingHandCursor

        onEntered: {
            parent.color="skyblue"
        }
        onExited: {
            parent.color="white"
        }
    }
}
