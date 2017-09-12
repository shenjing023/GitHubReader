#include "searchmodelworker.h"
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QEventLoop>
#include <QDebug>

SearchModelWorker::SearchModelWorker(QObject *parent) : QObject(parent)
  ,m_pManager(Q_NULLPTR)
{

}

SearchModelWorker::~SearchModelWorker()
{
    if(m_pManager!=Q_NULLPTR)
        delete m_pManager;
}

void SearchModelWorker::doWork(const QString &url)
{
    if(m_pManager==nullptr)
    {
        m_pManager=new QNetworkAccessManager();
    }
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
    QString list;
    list.append("{\"list\":{\"count\":");
    //先获取repository results
    QRegularExpression subRe("<h3>\\n(?<count>[.\\s\\S]*?) repository results\\n</h3>");
    QRegularExpressionMatch subMatch;
    subRe.setPatternOptions(QRegularExpression::InvertedGreedinessOption);
    subMatch=subRe.match(str);
    list.append("\""+subMatch.captured("count").trimmed()+"\",");

    list.append("\"results\":[");
    QRegularExpression re("<div class=\"repo-list-item [.\\s\\S]*>[.\\s\\S]*<h3>[.\\s\\S]*<a href=\"/(?<url>[.\\s\\S]*)\"[.\\s\\S]*</h3>(?<brief>[.\\s\\S]*)<p class=\"f6 text-gray mb-0 mt-2\">[.\\s\\S]*Updated [.\\s\\S]*>(?<update>[.\\s\\S]*)</relative-time>[.\\s\\S]*</p>[.\\s\\S]*<div class=\"d-table-cell col-2 text-gray pt-2\">(?<language>[.\\s\\S]*)</div>(?<star>[.\\s\\S]*)</div>");
    re.setPatternOptions(QRegularExpression::InvertedGreedinessOption);//设置匹配模式，是否贪婪
    QRegularExpressionMatchIterator i = re.globalMatch(str);

    while(i.hasNext()){
        QRegularExpressionMatch match = i.next();
        QString tmpList;
        tmpList.append("{");
        tmpList.append("\"url\":\""+match.captured("url")+"\",");   //url
        tmpList.append("\"title\":\""+match.captured("url")+"\","); //标题
        //简介
        if(match.captured("brief").trimmed().length()==0)
            tmpList.append("\"brief\":\"\",");
        else
        {
            subRe.setPattern("<p class=\"col-9 d-inline-block text-gray mb-2 pr-4\">(?<brief>[.\\s\\S]*)</p>");
            subMatch=subRe.match(match.captured("brief"));
            tmpList.append("\"brief\":\""+subMatch.captured("brief").replace("</em>","").replace("<em>","").replace("\"","").trimmed()+"\",");
        }
        //更新时间
        tmpList.append("\"update\":\"Updated on "+match.captured("update")+"\",");
        //语言
        if(match.captured("language").trimmed().length()==0)
        {
            tmpList.append("\"language\":\"\",");
            tmpList.append("\"languageColor\":\"\",");
        }
        else
        {
            subRe.setPattern("background-color:(?<languageColor>#\\w+);\"></span>(?<language>[.\\s\\S]*) $");
            subMatch=subRe.match(match.captured("language"));
            tmpList.append("\"language\":\""+subMatch.captured("language").trimmed()+"\",");
            tmpList.append("\"languageColor\":\""+subMatch.captured("languageColor").trimmed()+"\",");
        }
        //星数
        if(match.captured("star").trimmed().length()==0)
            tmpList.append("\"star\":\"\"");
        else
        {
            subRe.setPattern("[.\\s\\S]*</svg>(?<star>[.\\s\\S]*)</a>");
            subMatch=subRe.match(match.captured("star"));
            tmpList.append("\"star\":\""+subMatch.captured("star").trimmed()+"\"");
        }
        tmpList.append("},");
        list.append(tmpList);
    }
    list=list.left(list.length()-1);
    list.append("],");
    //前一页
    list.append("\"previous\":\"");
    subRe.setPattern("class=\"previous_page(?<previous>[.\\s\\S]*)Previous");
    subMatch=subRe.match(str);
    if(subMatch.captured("previous").contains("disabled"))
        list.append("disabled\",");
    else
    {
        QString t=subMatch.captured("previous");
        subRe.setPattern("href=\"(?<previous_url>[.\\s\\S]+)\">");
        subMatch=subRe.match(t);
        list.append(subMatch.captured("previous_url")+"\",");
    }
    //后一页
    list.append("\"next\":\"");
    subRe.setPattern("class=\"next_page(?<next>[.\\s\\S]*)Next");
    subMatch=subRe.match(str);
    if(subMatch.captured("next").contains("disabled"))
        list.append("disabled\",");
    else
    {
        QString t=subMatch.captured("next");
        subRe.setPattern("href=\"(?<next_url>[.\\s\\S]+)\">");
        subMatch=subRe.match(t);
        list.append(subMatch.captured("next_url")+"\",");
    }
    //语言过滤分类
    list.append("\"filter\":[");
    re.setPattern("<span class=\"bar\"[.\\s\\S]*<a href=\"(?<url>[.\\s\\S]+)\" class=\"filter-item\">[.\\s\\S]*>(?<count>[\\w,]+)</span>(?<language>[.\\s\\S]*)</a>");
    i=re.globalMatch(str);
    while(i.hasNext())
    {
        subMatch=i.next();
        QString tmpList;
        tmpList.append("{");
        tmpList.append("\"url\":\""+subMatch.captured("url").trimmed()+"\",");
        tmpList.append("\"count\":\""+subMatch.captured("count").trimmed()+"\",");
        tmpList.append("\"language\":\""+subMatch.captured("language").trimmed()+"\"");
        tmpList.append("},");
        list.append(tmpList);
    }
    list=list.left(list.length()-1);
    list.append("]}}");
    signal_dataDone(list);
}
