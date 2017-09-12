import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls 1.4 as Controls_14
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQml.Models 2.2
import QtWebEngine 1.5
import FileSystemModel 1.0

Item {
    id:root;
    property QtObject defaultProfile: WebEngineProfile {
        storageName: "Default"
    }
    Controls_14.SplitView{
        id:splitView;
        anchors.fill: parent
        orientation: Qt.Horizontal

        Controls_14.TreeView{
            id:filesView;
            height: parent.height;
            width: 200;
            Layout.minimumWidth: 200
            Layout.maximumWidth: 600
            sortIndicatorVisible:false;
            alternatingRowColors:false;
            horizontalScrollBarPolicy:Qt.ScrollBarAlwaysOff;
            model: fileSystemModel;
            rootIndex: rootPathIndex;
            selection: ItemSelectionModel{
                model: fileSystemModel;
            }

            style: TreeViewStyle{
                backgroundColor: "#252526"
                transientScrollBars:true
                branchDelegate: Label{
                    height: 10
                    leftPadding: 6*(styleData.depth+1)
                    font{
                        family: icomoonFont.name;
                        pixelSize: 12;
                    }
                    verticalAlignment: Text.AlignVCenter
                    text: styleData.isExpanded?"\uf84e":"\uf850"
                    color: "white"
                }
                handle: Rectangle {
                    implicitWidth: 5;
                    implicitHeight: 0;
                    color: "#2F3134";
                    anchors.fill: parent;
                    anchors.top: parent.top;
                    anchors.topMargin: 30;
                    anchors.right: parent.right;
                }
                scrollBarBackground:Rectangle{
                    anchors.top: parent.top;
                    anchors.topMargin: 30;
                    anchors.right: parent.right;
                    implicitWidth: 5;
                    implicitHeight: 0
                    color: "transparent"
                }
            }

            headerDelegate: Label{
                width: filesView.width
                height: 30;
                text: styleData.value;
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 20
                font{
                    family: "Microsoft YaHei"
                    pixelSize: 14
                }

                background: Rectangle{
                    anchors.fill: parent;
                    color: "#252526"

                    Rectangle{
                        anchors.bottom: parent.bottom;
                        width: parent.width
                        height: 1
                        color: "#383838"
                    }
                }
            }

            itemDelegate: Item {
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: styleData.selected?"white":"#CCCCCC"
                    elide: styleData.elideMode
                    text: {
                        if(styleData.value.substring(styleData.value.length-5)===".html"){
                            return styleData.value.substr(0,styleData.value.length-5);
                        }
                        else
                            return styleData.value;
                    }

                    leftPadding: 5
                    font{
                        family: "Microsoft YaHei"
                        pixelSize: 12
                    }
                }
            }

            rowDelegate: Rectangle{
                width: filesView.width
                height: 25
                color: styleData.selected?"#094771":"#252526";
            }

            Controls_14.TableViewColumn {
                title: "项目"
                role: "fileName"
                width: filesView.width
                movable: false;
            }

            onDoubleClicked : {
                var url = fileSystemModel.data(index,FileSystemModel.UrlStringRole);
                if(url!=="directory"){
                    //是否已经打开了
                    for(var i=0;i<tabs.count();++i){
                        var tab=tabs.getTab(i);
                        if(url==tab.item.url){
                            tabs.setCurrentIndex(i);
                            return;
                        }
                    }
                    tabs.createEmptyTab(root.defaultProfile,url);
                    tabs.setCurrentIndex(tabs.count()-1);
                }
                else{
                    if(isExpanded(index))
                        collapse(index);
                    else
                        expand(index);
                }
            }
        }

        HTMLTabView{
            id:tabs;
            Layout.minimumWidth: 200
            Layout.fillWidth: true
            Layout.fillHeight: true;
        }

        handleDelegate: Rectangle{
            implicitWidth: 0;
            implicitHeight: parent.height
            color: "#313131";
        }
    }
}
