<!--#include file="lib\__inc.asp"-->
<!--#include file="F.controller.asp"-->
<%
var r = F.get('r') || 'index';

if(r in F.controller){
    F.controller[r]();
}else{
    die('Error!');
}

log(new Date().getTime() - START)
// vim:ft=javascript
%>

