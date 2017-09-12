#include "mainwidget.h"
#include "./FileModel/filemodel.h"
#include "./SearchListModel/searchlistmodel.h"
#include <QQuickWidget>
#include <QVBoxLayout>
#include <QFileSystemModel>
#include <QtQml>
#include <QMenu>
#include <QAction>
#include <QSettings>

MainWidget::MainWidget(QWidget *parent)
    : QWidget(parent)
{
    setMinimumSize(1000,600);
    QQuickWidget *pWidget=new QQuickWidget(this);
    qmlRegisterUncreatableType<FileModel>("FileSystemModel", 1, 0,
                                          "FileSystemModel", "Cannot create a FileSystemModel instance.");
    qmlRegisterType<SearchListModel>("MySearchListModel",1,0,"MySearchListModel");
    QFileSystemModel *fsm=new FileModel(pWidget);
    //    ListModel *lm=new ListModel(pWidget);
    //    pWidget->rootContext()->setContextProperty("listModel",lm);
    pWidget->rootContext()->setContextProperty("fileSystemModel", fsm);
    pWidget->rootContext()->setContextProperty("rootPathIndex", fsm->index(fsm->rootPath()));
    pWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    pWidget->setSource(QUrl(QStringLiteral("qrc:/MainQML.qml")));
    QVBoxLayout *layout=new QVBoxLayout();
    layout->setMargin(0);
    layout->addWidget(pWidget);
    setLayout(layout);

    //系统托盘
    m_systemTray=new QSystemTrayIcon(this);
    m_systemTray->setIcon(QIcon(":/Images/github.png"));
    m_systemTray->setToolTip(QStringLiteral("GitHub文档阅读器"));
    QAction *action_show=new QAction(QIcon(":/Images/github.png"),QStringLiteral("显示"));
    QAction *action_quit=new QAction(QIcon(":/Images/close.png"),QStringLiteral("退出"));
    QMenu *trayMenu=new QMenu();
    trayMenu->addAction(action_show);
    trayMenu->addAction(action_quit);
    m_systemTray->setContextMenu(trayMenu);
    connect(action_show,&QAction::triggered,[this]{
        if(this->isHidden())
        {
            QSettings settings("MyCompany", "MyApp");
            this->restoreGeometry(settings.value("geometry").toByteArray());
            if(this->windowState()==Qt::WindowFullScreen)
                //时好时坏，目前还不知原因
                this->showFullScreen();
            else
                this->show();
            this->raise();
            this->activateWindow();
        }
    });
    connect(action_quit,&QAction::triggered,qApp,&QCoreApplication::quit);
    connect(m_systemTray,&QSystemTrayIcon::activated,this,&MainWidget::slot_activatedSysTrayIcon);
    m_systemTray->show();
}

MainWidget::~MainWidget()
{

}

void MainWidget::closeEvent(QCloseEvent *event)
{
    QSettings settings("MyCompany", "MyApp");
    settings.setValue("geometry", saveGeometry());
    this->hide();
    event->ignore();
}

void MainWidget::slot_activatedSysTrayIcon(QSystemTrayIcon::ActivationReason reason)
{
    switch (reason) {
    case QSystemTrayIcon::Trigger:
        //单击
        break;
    case QSystemTrayIcon::DoubleClick:
    {
        //双击
        if(this->isHidden())
        {
            QSettings settings("MyCompany", "MyApp");
            this->restoreGeometry(settings.value("geometry").toByteArray());
            if(this->windowState()==Qt::WindowFullScreen)
                this->showFullScreen();
            else
                this->show();
            this->raise();
            this->activateWindow();
        }
        break;
    }
    default:
        break;
    }
}
