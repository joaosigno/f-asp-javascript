<!--#include file="lib\__inc.asp"-->
<%

var db = new F.MsJetConnection('data.mdb');
db.open();
log(db.getJson('select * from code'));
db.close();


//log(new Date().getTime() - START)







// vim:ft=javascript
%>

