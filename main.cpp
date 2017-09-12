#include "mainwidget.h"
#include "singleapplication.h"
#include <QApplication>
#include <QSystemTrayIcon>
#include <QMessageBox>

int main(int argc, char *argv[])
{
    SingleApplication a(argc, argv);
    if(!a.isRunning())
    {
        QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
        QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
        //判断是否支持系统托盘
        if(!QSystemTrayIcon::isSystemTrayAvailable())
        {
            QMessageBox::critical(NULL,QStringLiteral("系统托盘"),QStringLiteral("不支持系统托盘"));
            exit(0);
        }
        MainWidget w;
        a.mainWidget=&w;
        w.show();

        return a.exec();
    }
    return 0;
}
