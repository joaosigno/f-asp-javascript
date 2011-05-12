<%
//数据库连接基类
F.Connection = function(){
    this._connectionString = '';
    this._connection = null;
    this._isOpen = false;
};


F.Connection.prototype = {
    open: function(){
        try{
            this._connection = new ActiveXObject("ADODB.Connection");
            this._connection.ConnectionString = this._connectionString;
            this._connection.Open();
            this._isOpen = true;
            return this;
        }catch(e){
            throw new Error('Connection open Error!');
        }
    },

    isOpen: function(){
        return this._isOpen;
    },

    close: function(){
        try{
            this._connection.Close();
            this._connection = null;
            this._isOpen = false;
            return this;
        }catch(e){
            throw new Error('Connection close Error!');
        }
    },

    execute: function(sql){
        return this._connection.Execute(sql);
    },

    getRecordSet: function(sql, cursorType, lockType){
        cursorType = cursorType || 1;
        lockType = lockType || 1;
        var rs = new ActiveXObject("ADODB.RecordSet");
        rs.Open(sql, this._connection, cursorType, lockType);
        return rs;
    },

    getJson: function(rs){
        if(typeof rs == 'string'){
            rs = this.getRecordSet(rs);
        }
        var fieldsCount = rs.Fields.Count;
        var json = {fields:[]}, push = Array.prototype.push;
        json.length = 0;
        for(var i=0; i<fieldsCount; i++){
            json.fields.push({
                name: rs.Fields(i).Name,
                type: rs.Fields(i).Type,
                desc: F.Connection.DataType[rs.Fields(i).Type] || 'unkonwn'
            });
        }
        while(!rs.Eof){
            var row = {};
            for(var i=0; i<json.fields.length; i++){
                var key = json.fields[i].name;
                row[key] = rs(key).Value;
            }
            push.call(json, row);
            rs.MoveNext();
        }
        return json;
    },

    insert: function(tableName, values){
        var rs = this.getRecordSet('select * from ' + tableName + ' where 1=2;', 1, 2);
        rs.AddNew();
        for(var i in values){
            rs(i) = values[i];
        }
        rs.Update();
        rs.Close();
    },

    update: function(sql, values){
        var rs = this.getRecordSet(sql, 2, 3);
        while(!rs.Eof){
            for(var i in values){
                rs(i) = values[i];
            }
            rs.Update();
            rs.MoveNext();
        }
        rs.Close();
    },

    tableNames: function(schemaName){
        return this.getSchemaNames('TABLE', 20, schemaName);
    },

    viewNames: function(schemaName){
        return this.getSchemaNames('VIEW', 20, schemaName);
    },

    columnNames: function(tableName){
        var names = [], 
        constraints = [undefined, undefined, tableName];
        var rs = this.getSchema(4, constraints);
        while(!rs.Eof){
            names.push(rs(3).Value);
            rs.MoveNext();
        }
        return names;
    },

    getHtmlTable: function(rs, opt){
        opt = opt || {};
        if(typeof rs == 'string'){
            rs = this.execute(rs);
        }
        var html = ['<table cellspacing="0">\n'];
        var fields = [];
        for (var e = new Enumerator(rs.Fields); !e.atEnd(); e.moveNext()) {
            fields.push(e.item().Name);
        }
        if(opt.caption){
            html.push('<caption>' + opt.caption + '</caption>\n');
        }
        html.push('<tr>\n');
        for(var i=0;i<fields.length;i++){
            html.push('<th>', fields[i], '</th>\n');
        }
        html.push('</tr>\n');
        var rowIndex = 0;
        while(!rs.Eof){
            rowIndex ++;
            html.push('<tr>');
            for (var e = new Enumerator(rs.Fields); !e.atEnd(); e.moveNext()) {
                var value = e.item().Value;
                switch(typeof value){
                case 'object':
                    if(! value){
                        value = '[Null]';
                    }else{
                        value = '[Object]';
                    }
                    break;
                case 'date':
                    value = new Date(value).toLocaleString();
                    break;
                case 'string':
                    value = value.length == 0 ? '[Empty]' : 
                    F.encodeHTML(value.length > 50 ? value.substr(0, 50) + '...' : value);
                    break;
                case 'unkonwn':
                    value = '[Binary]';
                    break;
                case 'number':
                    value = String(value);
                    break;
                }
                html.push('<td>',value, '</td>\n');
            }
            html.push('</tr>\n');
            if(rowIndex > 999){
                break;
            }
            rs.MoveNext();
        }
        html.push('</table>');
        return html.join('');
    },

    getSchemaNames: function(type, queryType, schemaName){
        var names = [];
        var constraints = [];
        if (schemaName) constraints[1] = schemaName;
        constraints[3] = type;
        var rs = this.getSchema(queryType, constraints);
        while (!rs.Eof) {
            names.push(rs(2).Value);
            rs.MoveNext();
        }
        return names;
    },

    getSchema: function(queryType, constraints){
        return this._connection.OpenSchema(queryType, constraints);
    }
};

F.Connection.DataType = {
    203 : "备注",
    7   : "时间/日期",
    128 : "二进制",
    11  : "布尔",
    6   : "货币",
    133 : "日期",
    135 : "日期时间",
    5   : "双精度",
    4   : "单精度",
    204 : "二进制",
    202 : "字符串",
    3   : "数字"
};

// vim:ft=javascript
%>
