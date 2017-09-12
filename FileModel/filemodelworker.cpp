#include "filemodelworker.h"
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QFile>
#include <QDir>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QTextStream>
#include <QEventLoop>
#include <QDebug>

FileModelWorker::FileModelWorker(const QString &url,QObject *parent) : QObject(parent)
  ,m_pManager(Q_NULLPTR)
  ,m_url(url)
{

}

FileModelWorker::~FileModelWorker()
{
    if(m_pManager!=Q_NULLPTR)
        delete m_pManager;
}

void FileModelWorker::doWork()
{
    if(m_pManager==Q_NULLPTR)
        m_pManager=new QNetworkAccessManager();
    //截取url中最后一段当做项目的目录
    QString proName=m_url.right(m_url.length()-19).replace("/","(")+")";
    getHTMLData(m_url,QDir::currentPath()+"/Temp/"+proName);
    signal_finished();
}

void FileModelWorker::getHTMLData(const QString &url, const QString &path)
{
    //构造请求
    QNetworkRequest request(url);
    request.setRawHeader("Referer","https://github.com/");
    request.setRawHeader("User-Agent","Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36");
    // 发送请求
    QNetworkReply *pReplay = m_pManager->get(request);
    // 开启一个局部的事件循环，等待响应结束，退出
    QEventLoop eventLoop;
    QObject::connect(m_pManager, &QNetworkAccessManager::finished, &eventLoop, &QEventLoop::quit);
    eventLoop.exec();
    // 获取响应信息
    QByteArray bytes = pReplay->readAll();

    QString str(bytes);
    QRegularExpression re("<tr class=\"js-navigation-item\"[.\\s\\S]*class=\"octicon (?<type>[\\w-]+)\"[.\\s\\S]*<td class=\"content\">[.\\s\\S]*<a href=\"(?<url>.*)\"[.\\s\\S]*>(?<title>.*)</a>[.\\s\\S]*</tr>");
    re.setPatternOptions(QRegularExpression::InvertedGreedinessOption);//设置匹配模式，是否贪婪
    QRegularExpressionMatchIterator i = re.globalMatch(str);
    while (i.hasNext()) {
        QRegularExpressionMatch match = i.next();
        if(match.captured("type")=="octicon-file-directory")  //目录
        {
            QString title=match.captured("title");
            if(title.contains("span"))
            {
                QRegularExpression subRe("<span.*>(?<first>.*)</span>(?<second>\\w+)");
                QRegularExpressionMatch match=subRe.match(title);
                if(match.hasMatch())
                {
                    title=match.captured("first").left(match.captured("first").length()-1)+"("+match.captured("second")+")";
                }
            }
            QDir dir(path);
            dir.mkdir(title);
            dir.cd(title);
            getHTMLData("https://github.com"+match.captured("url"),dir.absolutePath());
        }
        else if(match.captured("type")=="octicon-file-text")  //文件
        {
            QFile file(path+"/" +match.captured("title")+".html");
            if(!file.open(QIODevice::WriteOnly | QIODevice::Text))
            {
                qWarning()<<"open "<<match.captured("title")<<" failure!";
                qWarning()<<"error:"<<file.errorString();
            }
            else
            {
                request.setUrl("https://github.com"+match.captured("url"));
                pReplay = m_pManager->get(request);
                // 开启一个局部的事件循环，等待响应结束，退出
                QEventLoop eventLoop;
                QObject::connect(m_pManager, &QNetworkAccessManager::finished, &eventLoop, &QEventLoop::quit);
                eventLoop.exec();
                // 获取响应信息
                bytes = pReplay->readAll();
                QString s(bytes);
                QRegularExpression r;
                if(match.captured("title").contains(".md"))
                    r.setPattern("<div id=\"readme[.\\s\\S]*</article>[.\\s\\S]*</div>");
                else
                    r.setPattern("<table class=[.\\s\\S]*</table>");
                QRegularExpressionMatch m=r.match(s);

                QTextStream out(&file);
                out<<"<!DOCTYPE html>"<<"<html lang=\"en\">"
                  <<"<head>"
                 <<"<link crossorigin=\"anonymous\" href=\"https://assets-cdn.github.com/assets/frameworks-77c3b874f32e71b14cded5a120f42f5c7288fa52e0a37f2d5919fbd8bcfca63c.css\" media=\"all\" rel=\"stylesheet\" />"
                <<"<link crossorigin=\"anonymous\" href=\"https://assets-cdn.github.com/assets/github-9127cf9ba467dad0fd4917a7a402ad6cfa7b939bc149519d28b564124c740f3f.css\" media=\"all\" rel=\"stylesheet\" />"
                <<"</head>";

                if(m.hasMatch())
                {
                    out<<m.captured(0);
                    out<<"</html>";
                }
                file.close();
            }
        }
    }
}
