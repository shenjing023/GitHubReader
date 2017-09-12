import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "./QML"

Rectangle{
    id:root;
    width: 1000;
    height: 600;

    FontLoader{
        id:icomoonFont;
        source: "./Font/icomoon.ttf";
    }

    SearchView{
        id:searchView
        width: parent.width
        height: 50;

        onBackwardClicked: {
            layout.currentIndex=0;
        }
        onForewardClicked: {
            layout.currentIndex=1;
        }
        onReloadClicked: {

        }
        onSearchClicked: {
            layout.currentIndex=0;
            firstView.emitSignal(url);
        }
    }

    Rectangle{
        anchors.top: searchView.bottom
        width: parent.width
        height: 1
        color: "#B4B6B4"
    }

    StackLayout{
        id:layout;
        anchors.top: searchView.bottom
        anchors.topMargin: 1
        width: parent.width
        height: parent.height-searchView.height-1
        currentIndex: 0

        FirstView{
            id:firstView;
            width: 200
            height: 200
            onListItemClicked: {
                layout.currentIndex=1;
                fileSystemModel.getFileData(url);
            }
        }

        SecondView{
            id:secondView;
            width: parent.width
            height: parent.height-searchView.height-1
        }
    }
}
