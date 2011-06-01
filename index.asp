<!--#include file="lib\__inc.asp"-->
<!--#include file="F.controller.asp"-->
<%
var controller = F.get('r') || 'site';
var action = F.get('a') || 'index';
var fn = function(){
    if('_init' in F.controller[controller]){
        F.controller[controller]._init();
    }
    F.controller[controller][action]();
};
if(controller in F.controller){
    if(action in F.controller[controller] && action.substring(0,1) !== '_'){
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

