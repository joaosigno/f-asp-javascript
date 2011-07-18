<%@LANGUAGE="JavaScript" CODEPAGE="65001"%>
<%
var START = new Date().getTime();
%>
<!--#include file="prototype/__inc.asp"-->
<!--#include file="F.asp"-->
<!--#include file="F.string.asp"-->
<!--#include file="F.number.asp"-->
<!--#include file="F.date.asp"-->
<!--#include file="F.json.asp"-->
<!--#include file="F.session.asp"-->
<!--#include file="F.ajax.asp"-->
<!--#include file="F.cache.asp"-->
<!--#include file="F.cookie.asp"-->
<!--#include file="F.Connection.asp"-->
<!--#include file="F.ExcelConnection.asp"-->
<!--#include file="F.MsJetConnection.asp"-->
<!--#include file="F.MsSqlConnection.asp"-->
<!--#include file="F.File.asp"-->
<!--#include file="F.Folder.asp"-->
<!--#include file="F.Model.asp"-->
<!--#include file="F.Upload.asp"-->
<!--#include file="F.User.asp"-->
<!--#include file="F.Xml.asp"-->
<!--#include file="F.Zip.asp"-->
<%
Response.Charset = "utf8";
Session.CodePage = 65001;
Session.LCID = 2052;
Session.Timeout = 20;

//是否是调试状态
var DEBUG_MODE = false;
//模板变量
var __template_data = {
    page_title : '标题'
};

var echo = function(){
    for(var i=0, l=arguments.length; i<l; i++){
        if(typeof arguments[i] === 'object'){
            Response.Write(F.json.stringify(arguments[i]));
        }else{
            Response.Write(arguments[i]);
        }
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

var error = function(msg){
    assign('page_title', '错误');
    assign('error', msg || '未知错误');
    display('template/blog/error.html');
    die();
};

var debug = function(a, e){
    if(arguments.length === 1){
        e = a;
        a = debug;
    }
    if(DEBUG_MODE){
        var err;
        if(e instanceof Error){
            err = e; 
        }else{
            err = new Error();
            var s = Array.prototype.slice.call(arguments, 1);
            for(var i=0; i<s.length; i++){
                err['message'+i] = s[i]
            }
        }
        var msg = '';
        msg += ('<div style="color:#d00;"><b>DEBUG:</b>');
        msg += ('<pre>' + F.encodeHTML(a.callee.toString()) + '</pre>');
        msg += F.json.stringify(err);
        msg += ('</div>');
        error(msg);
    }else{
        error();
    }
};

var assign = function(key, value){
    __template_data[key] = value;
};

var display = function(tpl, data){
    var html = F.fetch(tpl, data || __template_data, {checkFile:true});
    echo(html);
    return html;
};

// vim:ft=javascript
%>
