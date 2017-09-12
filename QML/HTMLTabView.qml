import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls 1.4 as Controls_14
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.5

Item {
    id:root;
    property QtObject defaultProfile: WebEngineProfile {
        storageName: "Default"
    }
    function createEmptyTab(profile,url) {
        var tab = tabs.addTab("", tabComponent);

        // We must do this first to make sure that tab.active gets set so that tab.item gets instantiated immediately.
        tab.active = true;
        tab.item.url=url;
        tab.title = Qt.binding(function() {
            return tab.item.title.substr(0,tab.item.title.length-5);
        });
        tab.item.profile = profile;
        return tab;
    }
    function count(){
        return tabs.count;
    }
    function getTab(i){
        return tabs.getTab(i);
    }
    function setCurrentIndex(i){
        tabs.currentIndex=i;
    }

    Row{
        anchors.right: tabs.right;
        width: 60;
        height: 30;
        z:10
        visible: {
            if(tabs.count*150<=tabs.width)
                return false;
            else
                return true;
        }

        Button{
            flat: true;

            background: Rectangle{
                implicitWidth: 30
                implicitHeight: 30
                color: "dodgerblue"
            }

            contentItem: Label{
                font{
                    family: icomoonFont.name;
                    pixelSize: 12;
                }
                text: "\ufbd3";
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                tabs.currentIndex=tabs.currentIndex==0?0:tabs.currentIndex-1;
            }
        }

        Button{
            flat: true;

            background: Rectangle{
                implicitWidth: 30
                implicitHeight: 30
                color: "dodgerblue"
            }

            contentItem: Label{
                font{
                    family: icomoonFont.name;
                    pixelSize: 12;
                }
                text: "\ufbd4";
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                tabs.currentIndex=tabs.currentIndex==tabs.count-1?tabs.currentIndex:tabs.currentIndex+1;
            }
        }
    }

    Controls_14.TabView{
        id:tabs;
        anchors.fill: parent
        style: TabViewStyle {
            frameOverlap: 1
            tab: Rectangle {
                color: styleData.selected ? "steelblue" :"lightsteelblue"
                border.color:  "steelblue"
                implicitWidth: 150;
                implicitHeight: 30
                Text {
                    id: text
                    width: 125;
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                    text: styleData.title
                    color: styleData.selected ? "white" : "black"
                    elide: Text.ElideRight
                    font{
                        family: "Microsoft YaHei"
                        pixelSize: 12
                    }

                }
                Label{
                    anchors.left: text.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    font{
                        family: icomoonFont.name;
                        pixelSize: 14;
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "\uf750";
                    color: "black";

                    MouseArea{
                        anchors.fill: parent;
                        hoverEnabled: true;

                        onClicked: {
                            tabs.removeTab(styleData.index);
                        }
                        onEntered: {
                            parent.color="red"
                        }
                        onExited: {
                            parent.color="black"
                        }
                    }
                }
            }
            //frame: Rectangle { color: "steelblue" }
            tabBar: Rectangle{color:"#DCDCDC"}
        }

        Component{
            id: tabComponent;
            WebEngineView{
                id:webEngineView
                focus: true;

                settings.autoLoadImages: true
                settings.javascriptEnabled: true
                settings.errorPageEnabled: true
                settings.pluginsEnabled: true
                settings.fullScreenSupportEnabled: true
                settings.autoLoadIconsForPage: true
                settings.touchIconsEnabled: true
            }
        }
    }


}
