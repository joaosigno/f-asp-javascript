<%
//数据库连接基类
F.Connection = function(){
    this._connectionString = '';
    this._connection = null;
    this._isOpen = false;
};


F.Connection.prototype = {
    //连接是否打开
    isOpen: function(){
        return this._isOpen;
    },

    //打开连接
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

    //关闭连接
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

    //得到对应表的数据模型
    model: function(tableName){
        return new F.Model(tableName, this);
    },

    //执行sql
    execute: function(sql){
        return this._connection.Execute(sql);
    },

    //获取单个值
    executeScalar: function(sql){
        var rs = this.getRecordSet(sql), r;
        if(! rs.Eof){
            r = rs(0).Value;
            rs.Close();
        }else{
            throw new Error('No Result.');
        }
        return r;
    },

    //开始事务
    beginTrans: function(){
        this._connection.BeginTrans();
    },

    //回滚事务
    rollBackTrans: function(){
        this._connection.RollBackTrans();
    },

    //提交事务
    commitTrans: function(){
        this._connection.CommitTrans();
    },

    //获取记录集
    getRecordSet: function(sql, cursorType, lockType){
        cursorType = cursorType || 1;
        lockType = lockType || 1;
        var rs = new ActiveXObject("ADODB.RecordSet");
        rs.Open(sql, this._connection, cursorType, lockType);
        return rs;
    },

    //获取json对象
    getJson: function(rs){
        if(typeof rs == 'string'){
            rs = this.getRecordSet(rs);
        }
        var fieldsCount = rs.Fields.Count;
        var json = [], fields = [];
        for(var i=0; i<fieldsCount; i++){
            fields.push(rs.Fields(i).Name);
        }
        var l = fields.length;
        while(!rs.Eof){
            var row = {};
            for(var i=0; i<l; i++){
                row[fields[i]] = rs(fields[i]).Value;
            }
            json.push(row);
            rs.MoveNext();
        }
        rs.Close();
        return json;
    },

    //向表中插入一条记录
    insert: function(tableName, values){
        var rs = this.getRecordSet('select * from ' + tableName + ' where 1=2;', 1, 2);
        rs.AddNew();
        for(var i in values){
            rs(i) = values[i];
        }
        rs.Update();
        rs.Close();
    },

    //更新记录集数据
    update: function(rs, values){
        if(typeof rs == 'string'){
            rs = this.getRecordSet(rs, 2, 3);
        }
        while(!rs.Eof){
            for(var i in values){
                rs(i) = values[i];
            }
            rs.Update();
            rs.MoveNext();
        }
        rs.Close();
    },

    //获取表名数组
    tableNames: function(schemaName){
        return this.getSchemaNames('TABLE', 20, schemaName);
    },

    //获取视图名数组
    viewNames: function(schemaName){
        return this.getSchemaNames('VIEW', 20, schemaName);
    },

    //返回记录集的表格html
    getHtmlTable: function(rs, opt){
        opt = opt || {};
        if(typeof rs == 'string'){
            rs = this.execute(rs);
        }
        var html = ['<table cellspacing="0" border="1">\n'];
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
        var rowIndex = 0, fieldsLength = fields.length;
        while(!rs.Eof){
            rowIndex ++;
            html.push('<tr>');
            for (var i=0; i<fieldsLength; i++) {
                var value = rs(fields[i]).Value;
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
        rs.Close();
        html.push('</table>');
        return html.join('');
    },

    //查询schema
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
        rs.Close();
        return names;
    },

    //获取schema
    getSchema: function(queryType, constraints){
        return this._connection.OpenSchema(queryType, constraints);
    }
};

// vim:ft=javascript
%>
