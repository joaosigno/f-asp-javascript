<%@LANGUAGE="JavaScript" CODEPAGE="65001"%>
<%
var START = new Date().getTime();
%>
<!--#include file="prototype/__inc.asp"-->
<!--#include file="F.asp"-->
<!--#include file="F.Connection.asp"-->
<!--#include file="F.ExcelConnection.asp"-->
<!--#include file="F.File.asp"-->
<!--#include file="F.Folder.asp"-->
<!--#include file="F.Model.asp"-->
<!--#include file="F.MsJetConnection.asp"-->
<!--#include file="F.Smarty.asp"-->
<!--#include file="F.Upload.asp"-->
<!--#include file="F.User.asp"-->
<!--#include file="F.Xml.asp"-->
<!--#include file="F.Zip.asp"-->
<!--#include file="F.ajax.asp"-->
<!--#include file="F.cache.asp"-->
<!--#include file="F.cookie.asp"-->
<!--#include file="F.json.asp"-->
<!--#include file="F.session.asp"-->
<!--#include file="F.string.asp"-->
<!--#include file="F.util.asp"-->
<%
Response.Charset="utf8";
Session.CodePage=65001;

//是否是调试状态
var DEBUG_MODE = false;
//模板变量
var __template_data = {
    page_title : '标题'
};


var echo = function(){
    for(var i=0, l=arguments.length; i<l; i++){
        Response.Write(arguments[i]);
    }
};

var die = function(){
    echo.apply(this, arguments);
    Response.End();
};

var log = function(s){
    echo('<div style="background:#ddd;padding:3px;margin:3px 0;font-size:12px;">',
        F.encodeHTML(F.json.stringify({DATA:arguments.length > 0 ? s : __template_data}).slice(8, -1)),
    '</div>');
    Response.Flush();
};

var debug = function(a, e){
    if(DEBUG_MODE){
        echo('<div style="color:#d00;"><b>DEBUG:</b>');
        echo('<pre>' + F.encodeHTML(a.callee.toString()) + '</pre>');
        log(e)
        echo('</div>');
    }
};

var assign = function(key, value){
    __template_data[key] = value;
};

var display = function(tpl, data){
    var str = new F.File(tpl).getText();
    var html = str.fetch(data || __template_data);
    echo(html);
    return html;
};

//为smarty插件配置include
F.Smarty.prototype.getTemplate = function(file){
    return new F.File('template/' + file).getText();
};


// vim:ft=javascript
%>
