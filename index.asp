<!--#include file="lib\__inc.asp"-->
<!--#include file="F.controller.asp"-->
<%
var controller = F.get('r') || 'site';
var action = F.get('a') || 'index';


if(controller in F.controller){
    if(action in F.controller[controller] && action.substring(0,1) !== '_'){
        F.controller[controller][action]();
    }else{
        die('Error 2');
    }
}else{
    die('Error 1');
}

log(F.url());
log(new Date().getTime() - START)

// vim:ft=javascript
%>

