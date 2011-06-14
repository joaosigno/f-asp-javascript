<%
F.MsSqlConnection = function(dataSource, initialCatalog, userId, password){
    F.Connection.call(this);

    this._connectionString = 
        "Provider=SQLOLEDB; " +
        "Data Source=" + dataSource + "; " +
        "Initial Catalog=" + initialCatalog + "; " +
        "User Id=" + userId + "; " +
        "Password=" + password + ";";

};
F.inherits(F.MsSqlConnection, F.Connection);

// vim:ft=javascript
%>
