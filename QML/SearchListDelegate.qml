import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id:root
    property string url;    //url
    property string title;  //标题
    property string language;//语言
    property string languageColor;   //圆的颜色
    property string stars;  //star数
    property string brief;    //项目的主要描述
    property string updateTime; //更新时间

    signal itemClicked(string url); //点击item，跳转界面
    height: column.height
    color: "white"
    Column{
        id:column;
        width: parent.width-20
        anchors.left: parent.left
        anchors.leftMargin: 10
        spacing: 10

        Row{
            width: parent.width
            height: 30
            spacing: 0
            Label{
                width: parent.width/2
                height: parent.height
                text: root.title
                font{
                    family: "Microsoft YaHei"
                    pixelSize: 16
                }
                color: "#0366D6"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            Rectangle{
                width: parent.width/4
                height: parent.height
                color: "transparent"
                Rectangle{
                    width: 15
                    height: 15
                    radius: 15
                    color: root.languageColor==""?"transparent":root.languageColor
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.languageColor==""?false:true
                }
                Label{
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.language
                    font{
                        family: "Microsoft YaHei"
                        pixelSize: 14
                    }
                    color: "gray"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    visible: root.language==""?false:true
                }
            }
            Rectangle{
                width: parent.width/4
                height: parent.height
                color: "transparent"
                Label{
                    id:star;
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\ufb8a"
                    font{
                        family: icomoonFont.name;
                        pixelSize: 16;
                    }
                    //color: "gray"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                Label{
                    anchors.left: star.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.stars
                    font{
                        family: "Microsoft YaHei"
                        pixelSize: 16
                    }
                    color: "gray"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                visible: root.stars==""?false:true
            }
        }

        Label{
            width: parent.width/3
            text: root.brief
            font{
                family: "Microsoft YaHei"
                pixelSize: 14
            }
            color: "gray"
            horizontalAlignment: Text.AlignLeft
            maximumLineCount: 3
            wrapMode:Text.WordWrap
            elide: Text.ElideRight
            visible: root.brief==""?false:true
        }

        Label{
            width: parent.width/2
            text: root.updateTime
            font{
                family: "Microsoft YaHei"
                pixelSize: 14
            }
            color: "gray"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Rectangle{
            width: parent.width
            height: 1
            color: "#E1E4E8"
        }
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
        onClicked: {
            itemClicked("https://github.com/"+root.url);
        }
    }
}
