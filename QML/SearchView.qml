import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id:root;
    color: "transparent"

    signal backwardClicked();
    signal forewardClicked();
    signal reloadClicked();
    signal searchClicked(string url);

    Button{
        id:backwardBtn;
        width: 30;
        height: 30
        anchors{
            left: parent.left
            leftMargin: 10
            top:parent.top;
            topMargin: 10
        }
        flat: true

        contentItem: Label{
            text: "\uf4cf";
            font{
                family: icomoonFont.name;
                pixelSize: 18;
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: backwardBtn.enabled?"#27292B":"#D4D4D4";
        }
        background: Rectangle{
            color: parent.hovered?"#DFDFDF":"transparent"
            radius: {
                if(parent.pressed)
                    return 15;
                else
                    return 0;
            }
        }

        ToolTip.visible: hovered;
        ToolTip.delay: 500;
        ToolTip.text: qsTr("点击可后退");

        onClicked: {
            backwardClicked();
        }
    }

    Button{
        id:forewardBtn;
        width: 30;
        height: 30
        anchors{
            left: backwardBtn.right
            //leftMargin: 20
            top:parent.top;
            topMargin: 10
        }
        flat: true

        contentItem: Label{
            text: "\uf4d0";
            font{
                family: icomoonFont.name;
                pixelSize: 18;
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: forewardBtn.enabled?"#27292B":"#D4D4D4";
        }
        background: Rectangle{
            color: parent.hovered?"#DFDFDF":"transparent"
            radius: {
                if(parent.pressed)
                    return 15;
                else
                    return 0;
            }
        }

        ToolTip.visible: hovered;
        ToolTip.delay: 500;
        ToolTip.text: qsTr("点击可前进");

        onClicked: {
            forewardClicked();
        }
    }

    Button{
        id:reloadBtn;
        width: 30;
        height: 30
        anchors{
            left: forewardBtn.right
            //leftMargin: 20
            top:parent.top;
            topMargin: 10
        }
        flat: true

        contentItem: Label{
            text: "\uf4c1";
            font{
                family: icomoonFont.name;
                pixelSize: 18;
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle{
            color: parent.hovered?"#DFDFDF":"transparent"
            radius: {
                if(parent.pressed)
                    return 15;
                else
                    return 0;
            }
        }

        ToolTip.visible: hovered;
        ToolTip.delay: 500;
        ToolTip.text: qsTr("重新加载");

        onClicked: {
            reloadClicked();
        }
    }

    TextField {
          id: searchText
          anchors{
              left: reloadBtn.right
              leftMargin: 10
              top:parent.top;
              topMargin: 10
              right: searchBtn.left
              rightMargin: 10
          }
          height: 30
          font{
              family: "Microsoft YaHei"
              pixelSize: 14
          }
          placeholderText: qsTr("输入关键词")
          selectByMouse: true;

          background: Rectangle {
              anchors.fill: parent
              color: searchText.enabled ? "transparent" : "#353637"
              border.color: searchText.enabled ? "lightsteelblue" : "transparent"
          }

          Keys.enabled: true;
          Keys.onReturnPressed: {
              if(searchText.text.trim().length==0)
                  return;
              //特殊字符转码
              searchClicked("https://github.com/search?utf8=%E2%9C%93&type=Repositories&q="+encodeURIComponent(searchText.text));
          }
      }

    Button{
        id:searchBtn;
        width: 50;
        height: 30
        anchors{
            right: parent.right
            rightMargin: 10
            top:parent.top;
            topMargin: 10
        }
        flat: true

        contentItem: Label{
            text: "\uf495";
            font{
                family: icomoonFont.name;
                pixelSize: 18;
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle{
            color: parent.hovered?"#DFDFDF":"transparent"
            radius: {
                if(parent.pressed)
                    return 30;
                else
                    return 0;
            }
        }

        ToolTip.visible: hovered;
        ToolTip.delay: 500;
        ToolTip.text: qsTr("点击可搜索");

        onClicked: {
            if(searchText.text.trim().length==0)
                return;
            //特殊字符转码
            searchClicked("https://github.com/search?utf8=%E2%9C%93&type=Repositories&q="+encodeURIComponent(searchText.text));
        }
    }
}
