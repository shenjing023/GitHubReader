#include "searchlistmodel.h"
#include <QThread>
#include <QDebug>

SearchListModel::SearchListModel(QObject *parent) : QObject(parent)
  ,pWork(new SearchModelWorker())
  ,m_isRunning(false)
{
    m_thread=new QThread();
    pWork.data()->moveToThread(m_thread);
    connect(this,&SearchListModel::signal_listData,pWork.data(),&SearchModelWorker::doWork);
    connect(pWork.data(),&SearchModelWorker::signal_dataDone,this,&SearchListModel::slot_dataDone);
    connect(m_thread,&QThread::finished,m_thread,&QThread::deleteLater);
    m_thread->start();
}

SearchListModel::~SearchListModel()
{
    m_thread->quit();
    m_thread->wait();
}

void SearchListModel::slot_dataDone(const QString &list)
{
    m_isRunning=false;
    signal_dataDone(list);
}

void SearchListModel::getListData(const QString &url)
{
    if(!m_isRunning)
    {
        signal_listData(url);
        m_isRunning=true;
    }
}
