<!--#include file="lib\__inc.asp"-->
<%

var db = new F.MsJetConnection('data.mdb').open();
echo(db.getHtmlTable('learning'));
db.close();


log(new Date().getTime() - START)







// vim:ft=javascript
%>

