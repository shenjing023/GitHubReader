import QtQuick 2.9
import QtQuick.Controls 2.2
import MySearchListModel 1.0

Rectangle {
    property string previousUrl;    //前一页url
    property string nextUrl;        //后一页url
    property string question;   //搜索词
    id:root;
    anchors.fill: parent;

    function emitSignal(url){
        //进度条是否运行中
        if(!timer.running){
            myListModel.getListData(url);
            root.question=url.substr(61);
            //root.index=0;
            comboBoxModel.clear();
            var comboBoxModelObj={
                type:["Best match","Most stars","Fewest stars","Most forks","Fewest forks","Recently updated","Least recently updated"],
                url:["https://github.com/search?o=desc&s=&type=Repositories&utf8=%E2%9C%93&q="+question,
                    "https://github.com/search?o=desc&s=stars&type=Repositories&utf8=%E2%9C%93&q="+question,
                    "https://github.com/search?o=asc&s=stars&type=Repositories&utf8=%E2%9C%93&q="+question,
                    "https://github.com/search?o=desc&s=forks&type=Repositories&utf8=%E2%9C%93&q="+question,
                    "https://github.com/search?o=asc&s=forks&type=Repositories&utf8=%E2%9C%93&q="+question,
                    "https://github.com/search?o=desc&s=updated&type=Repositories&utf8=%E2%9C%93&q="+question,
                    "https://github.com/search?o=asc&s=updated&type=Repositories&utf8=%E2%9C%93&q="+question
                ]
            }
            for(var k=0;k<7;++k){
                comboBoxModel.append({
                                         "type":comboBoxModelObj["type"][k],
                                         "url":comboBoxModelObj["url"][k]
                                     });
            }
            comboBoxcontrol.currentIndex=0;
            //重置进度条
            progressBar.value=0;
            timer.start();
        }
    }

    signal listItemClicked(string url);

    MySearchListModel{
        id:myListModel;
        onSignal_dataDone: {//console.log(list)
            try{
                var json=JSON.parse(list);
                root.previousUrl=json["list"]["previous"];
                root.nextUrl=json["list"]["next"];
                //repository results
                topRect.totalCount=json["list"]["count"];
                listModel.clear();
                var results=json["list"]["results"];
                for(var i=0;i<results.length;++i){
                    listModel.append({
                                         "_url":results[i]["url"],
                                         "_title":results[i]["title"],
                                         "_language":results[i]["language"],
                                         "_languageColor":results[i]["languageColor"],
                                         "_stars":results[i]["star"],
                                         "_brief":results[i]["brief"],
                                         "_updateTime":results[i]["update"]
                                     });
                }
                filterListModel.clear();
                results=json["list"]["filter"];
                for(var j=0;j<results.length;++j){
                    filterListModel.append({
                                               "_url":results[j]["url"],
                                               "_count":results[j]["count"],
                                               "_language":results[j]["language"]
                                           });
                }
                errorRect.visible=false;
                leftRect.visible=true;
                rightRect.visible=true;
            }
            catch(error){
                errorRect.visible=true;
                leftRect.visible=false;
                rightRect.visible=false;
            }
            finally{
                timer.stop();
                progressBar.value=100;
            }
        }
    }

    ListModel {
        id:listModel;
    }

    ListModel{
        id:filterListModel;
    }

    ListModel{
        id:comboBoxModel;
    }

    ProgressBar{
        id:progressBar;
        anchors{
            top:parent.top
            topMargin: -1
        }
        from:0
        to:100
        value: 0
        visible: value!=0&&value!=100

        background: Rectangle {
            implicitWidth: root.width
            implicitHeight: 2
            color: "#e6e6e6"
        }
        contentItem: Item {
            implicitWidth: root.width
            implicitHeight: 2

            Rectangle {
                width: progressBar.visualPosition * parent.width
                height: parent.height
                color: "springgreen"
            }
        }
        Timer{
            id:timer;
            interval: 50
            repeat: true;
            running: false;
            onTriggered: {
                if(progressBar.value<=90)
                    progressBar.value=progressBar.value+1
            }
        }
    }

    //解析json错误时显示
    Rectangle{
        id:errorRect;
        anchors.fill: parent;
        visible: false;

        Text{
            anchors.centerIn: parent
            text: qsTr("解析页面失败!!!");
            font{
                family: "Microsoft YaHei"
                pixelSize: 24
            }
        }
    }

    Rectangle{
        id:leftRect;
        width: parent.width-300
        anchors{
            left: parent.left
            leftMargin: 20;
            top:parent.top
            topMargin: 20
            bottom: parent.bottom
            bottomMargin: 20
        }
        color: "white"
        visible: false;
        Rectangle{
            property string totalCount: "0"
            id:topRect;
            width: parent.width
            height: 50
            color: "transparent"

            Label{
                height: parent.height
                font{
                    family: "Microsoft YaHei"
                    pixelSize: 16
                }
                leftPadding: 20
                text: parent.totalCount+" repository results";
                color: "black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                id: comboBoxcontrol
                anchors.right: parent.right
                anchors.rightMargin: 10
                width: 140
                height: 30
                anchors.verticalCenter: parent.verticalCenter
                font{
                    family: "Microsoft YaHei"
                    pixelSize: 14
                }
                textRole: "type"
                displayText: "Sort: "+currentText
                model: comboBoxModel;
                delegate: ItemDelegate {
                    width: comboBoxcontrol.width
                    contentItem: Text {
                        text: type
                        color: "black"
                        font: comboBoxcontrol.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: comboBoxcontrol.highlightedIndex === index
                    onClicked: {
                        if(comboBoxcontrol.highlightedIndex !== index){
                            //重置进度条
                            progressBar.value=0;
                            timer.start();
                            myListModel.getListData(url);
                        }
                    }
                }

                indicator: Canvas {
                    id: canvas
                    x: comboBoxcontrol.width - width - comboBoxcontrol.rightPadding
                    y: comboBoxcontrol.topPadding + (comboBoxcontrol.availableHeight - height) / 2
                    width: 12
                    height: 8
                    contextType: "2d"

                    Connections {
                        target: comboBoxcontrol
                        onPressedChanged: canvas.requestPaint()
                    }

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = comboBoxcontrol.pressed ? "black" : "black";
                        context.fill();
                    }
                }

                contentItem: Text {
                    leftPadding: 5
                    rightPadding: comboBoxcontrol.indicator.width + comboBoxcontrol.spacing

                    text: comboBoxcontrol.displayText
                    font: comboBoxcontrol.font
                    color: "black"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight

                }

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    border.color: comboBoxcontrol.pressed ? "dimgray" : "darkgrey"
                    border.width: comboBoxcontrol.visualFocus ? 2 : 1
                    radius: 2
                }

                popup: Popup {
                    y: comboBoxcontrol.height - 1
                    width: comboBoxcontrol.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: comboBoxcontrol.popup.visible ? comboBoxcontrol.delegateModel : null
                        currentIndex: comboBoxcontrol.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        border.color: "darkgrey"
                        radius: 2
                    }
                }

                onActivated: {
                    comboBoxcontrol.width=(displayText.length)*8+12
                }
            }
        }

        Rectangle{
            anchors.top: topRect.bottom
            width: parent.width
            height: 1
            color: "#E1E4E8"
        }

        ListView {
            id:listView;
            anchors.top: topRect.bottom
            anchors.topMargin: 1
            width: parent.width
            height: parent.height-topRect.height-1-50
            clip: true
            boundsBehavior:Flickable.StopAtBounds
            model: listModel
            delegate: SearchListDelegate{
                width: parent.width
                url:_url;
                title: _title;
                language: _language;
                languageColor: _languageColor;
                stars: _stars;
                brief: _brief;
                updateTime: _updateTime;
                onItemClicked: {
                    listItemClicked(url);
                }
            }
            focus: true
            ScrollBar.vertical: ScrollBar { }
        }

        Row{
            id:bottomRow;
            anchors.top: listView.bottom;
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: 180;
            height: 40;
            spacing: 0

            Label{
                id:previousBtn;
                width: 70
                height: parent.height
                text: "Previous";
                font{
                    family: "Microsoft YaHei"
                    pixelSize: 14
                }
                color:root.previousUrl=="disabled"?"#D8D5DA":"#0366D8"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                background: Rectangle{
                    color: "transparent"
                    border{
                        color: "#E1E4E8"
                        width: 1
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true;
                    cursorShape: root.previousUrl=="disabled"?Qt.ArrowCursor:Qt.PointingHandCursor

                    onClicked: {
                        if(root.previousUrl!="disabled"){
                            //重置进度条
                            progressBar.value=0;
                            timer.start();
                            myListModel.getListData("https://github.com"+root.previousUrl);
                        }
                    }
                }
            }
            Label{
                width: 50
                height: parent.height
                text: "...";
                font{
                    family: "Microsoft YaHei"
                    pixelSize: 14
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                background: Rectangle{
                    color: "transparent"
                    border{
                        color: "#E1E4E8"
                        width: 1
                    }
                }
            }
            Label{
                id:nextBtn;
                width: 60
                height: parent.height
                text: "Next";
                font{
                    family: "Microsoft YaHei"
                    pixelSize: 14
                }
                color:root.nextUrl=="disabled"?"#D8D5DA":"#0366D8"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                background: Rectangle{
                    color: "transparent"
                    border{
                        color: "#E1E4E8"
                        width: 1
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true;
                    cursorShape: root.nextUrl=="disabled"?Qt.ArrowCursor:Qt.PointingHandCursor

                    onClicked: {
                        if(root.nextUrl!="disabled"){
                            //重置进度条
                            progressBar.value=0;
                            timer.start();
                            myListModel.getListData("https://github.com"+root.nextUrl);
                        }
                    }
                }
            }
        }
    }

    Rectangle{
        id:rightRect;
        width: 200;
        height: parent.height-40
        anchors{
            right: parent.right
            rightMargin: 20
            top:parent.top
            topMargin: 20
        }
        color: "white"
        visible: false;
        Label{
            width: parent.width
            height: 40
            text: "Languages"
            font{
                family: "Microsoft YaHei"
                pixelSize: 16
            }
            leftPadding: 20
            topPadding: 20
        }

        ListView{
            id:filterListView;
            anchors{
                top:rightRect.top
                topMargin: 45
                left: rightRect.left
                leftMargin: 20
                right: rightRect.right
                rightMargin: 20
                bottom: rightRect.bottom
                bottomMargin: 20
            }
            clip: true
            boundsBehavior:Flickable.StopAtBounds
            model: filterListModel
            delegate: FilterDelegate{
                language: _language;
                url:_url;
                count:_count;
            }
            focus: true
            ScrollBar.vertical: ScrollBar { }
        }
    }
}
