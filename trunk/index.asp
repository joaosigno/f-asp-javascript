<!--#include file="lib\__inc.asp"-->
<!--#include file="F.controller.asp"-->
<%
var CONTROLLER = F.get('r') || 'site';
var ACTION = F.get('a') || 'index';
var fn = function(){
    if('_init' in F.controller[CONTROLLER]){
        F.controller[CONTROLLER]._init();
    }
    F.controller[CONTROLLER][ACTION]();
};
if(CONTROLLER in F.controller){
    if(ACTION in F.controller[CONTROLLER] && ACTION.substring(0,1) !== '_'){
        if(DEBUG_MODE){
            fn();
            log(new Date().getTime() - START)
        }else{
            try{
                fn();
            }catch(e){
                echo('<div>Sorry, we will back soon..</div>');
            }
        }
    }else{
        die('Error 2');
    }
}else{
    die('Error 1');
}

// vim:ft=javascript
%>

