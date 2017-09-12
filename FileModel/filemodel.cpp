#include "filemodel.h"
#include "filemodelworker.h"
#include <QUrl>
#include <QScopedPointer>
#include <QDir>
#include <QThread>
#include <QMessageBox>
//#include <QCoreApplication>
#include <QDebug>

FileModel::FileModel(QObject *parent):QFileSystemModel(parent)
{
    QDir dir(QDir::currentPath()+"/Temp");
    if(!dir.exists())
    {
        //存放项目的临时文件夹
        QDir d(QDir::currentPath());
        d.mkdir("Temp");
    }
    else
    {
        //先删再建
        deleteTmpDir(QDir::currentPath()+"/Temp");
        QDir d(QDir::currentPath());
        if(!d.mkdir("Temp"))
        {
            QMessageBox::critical(NULL,QStringLiteral("错误"),QStringLiteral("创建临时文件夹失败!\n查看文档功能将不能使用"));
        }
    }
    setRootPath(QDir::currentPath()+"/Temp");
    setResolveSymlinks(true);
}

FileModel::~FileModel()
{
    //当线程还没有结束就强制关闭，会删不干净，所以需要在构造函数中先清空该文件夹
    deleteTmpDir(QDir::currentPath()+"/Temp");
}

void FileModel::deleteTmpDir(const QString &dirName)
{
    QDir dir(dirName);
    if (dir.exists(dirName))
    {
        for(const QFileInfo &info : dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst))
        {
            if (info.isDir())
            {
                deleteTmpDir(info.absoluteFilePath());
            }
            else
            {
                QFile::remove(info.absoluteFilePath());
            }
        }
        dir.rmdir(dirName);
    }
}

void FileModel::getFileData(const QString &url)
{
    //截取url中最后一段当做项目的目录
    QDir dir(QDir::currentPath()+"/Temp");
    if(dir.mkdir(url.right(url.length()-19).replace("/","(")+")"))
    {
        FileModelWorker *work=new FileModelWorker(url);
        QThread *thread=new QThread();
        work->moveToThread(thread);
        connect(thread,&QThread::started,work,&FileModelWorker::doWork);
        connect(work,&FileModelWorker::signal_finished,thread,&QThread::quit);
        connect(thread,&QThread::finished,thread,&QThread::deleteLater);
        connect(work,&FileModelWorker::signal_finished,work,&FileModelWorker::deleteLater);
        thread->start();
    }
}

QVariant FileModel::data(const QModelIndex &index, int role) const
{
    if(index.isValid())
    {
        switch(role){
        case UrlStringRole:
        {
            if(isDir(index))
                return QVariant("directory");
            return QVariant(QUrl::fromLocalFile(filePath(index)).toString());
        }
        default:
            break;
        }
    }
    return QFileSystemModel::data(index, role);
}
