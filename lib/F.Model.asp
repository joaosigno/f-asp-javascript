<%
//tableName: 需要操作的表名
//connection: F.Connection实例
F.Model = function(tableName, connection){
    this.tableName = tableName;
    this.connection = connection;
    //获取schema约束条件
    this._constraints = [null, null, this.tableName];
    //主键
    this._primaryKey = null;
};

F.Model.prototype = {

    //获取表的主键
    pk: function(){
        if(this._primaryKey){
            return this._primaryKey;
        }else{
            var rs = this.connection.getSchema(28, this._constraints);
            if(rs.Eof){
                return null;
            }else{
                this._primaryKey = rs('COLUMN_NAME').Value;
                return this._primaryKey;
            }
        }
    },

    //获取表的列名数组
    fields: function(){
        var r = [];
        var rs = this.connection.getSchema(4, this._constraints);
        var name, type;
        while(!rs.Eof){
            type = rs('DATA_TYPE').Value;
            name = rs('COLUMN_NAME').Value;
            r.push({
                name: name,
                type: type,
                desc: F.Model.AdoDataType[type].name,
                base: F.Model.AdoDataType[type].type
            });
            rs.MoveNext();
        }
        rs.Close();
        return r;
    },

    //统计数量
    count: function(where){
        where = this._getWhereString(where);
        var sql = 'select count(*) from ' + this.tableName + where;
        return this.connection.executeScalar(sql);
    },

    //分页，可以满足基本的使用
    page: function(page, count, fields, order, linkCount){
        var p = {},
        total = this.count(),
        pk = this.pk(),
        count = count || 10,
        totalPage = Math.ceil(total/count),
        fields = fields || '*',
        order = 'order by ' + (order ? order : pk),
        currentPage = parseInt(page || 1),
        linkCount = linkCount || 10;
        if(isNaN(currentPage) || currentPage < 1){
            currentPage = 1;
        }else if(currentPage > totalPage){
            currentPage = totalPage;
        }
        var sql = 'select top ' + count + 
            ' ' + fields + ' from ' + this.tableName + 
            (currentPage > 1 ? (' where ' + pk + 
            ' not in ( select top ' + (count*(currentPage-1)) + 
            ' ' + pk + ' from ' + this.tableName + ' ' + order + 
            ') ') : ' ' ) + order;
        var data = this.connection.getJson(sql);
        var numbers = [], half = Math.ceil(linkCount/2), i = 0, 
        maxNum = (currentPage+half)<totalPage ? currentPage + half : totalPage;
        while(i++ < linkCount){
            if(maxNum > 0){
                numbers.unshift(maxNum);
            }
            maxNum --;
        }
        var r = {
            'total' : totalPage,
            'current' : currentPage,
            'count' : count,
            'isFirst' : currentPage === 1,
            'isLast' : currentPage === total,
            'data' : data,
            'numbers' :  numbers
        };
        return r;
    },

    //查找符合条件的全部结果
    findAll: function(where, fields, order, limit, isRecordSet){
        where = this._getWhereString(where);
        fields = fields || '*';
        order = order ? ' order by ' + order : '';
        limit = isNaN(parseInt(limit)) ? '' : 'top ' + limit + ' ';
        var sql = 'select ' + limit + fields + ' from ' + this.tableName + where + order; 
        var rs = this.connection.execute(sql);
        return isRecordSet ? rs : this.connection.getJson(sql);
    },

    //查找一个符合条件的数据
    find: function(where, fields, order){
        var r = this.findAll(where, fields, order, 1);
        return r.length == 1 ? r[0] : null;
    },

    //插入数据
    insert: function(values){
        this.connection.insert(this.tableName, values);
    },

    //更新数据,先查找需要修改的，改成第二个参数的数据
    update: function(where, values){
        var sql = 'select * from ' + this.tableName + this._getWhereString(where);
        this.connection.update(sql, values);
    },

    //删除数据
    del: function(where){
        var sql = 'delete from ' + this.tableName + this._getWhereString(where);
        this.connection.execute(sql);
    },

    //得到表的html
    html: function(where, fields, order, limit){
        return this.connection.getHtmlTable(this.findAll(where, fields, order, limit, 1));
    },

    //内部函数，用来获取where语句
    _getWhereString: function(where){
        if(where === undefined){
            where = '';
        }else if(F.isArray(where)){
            where = where.join(' and ');
        }else if(F.isNumber(where)){
            where = this.pk() + '=' + where; 
        }
        return where === '' ? '' : ' where ' + where;
    }

};

//基本类型
F.Model.BaseType = {
    'unknown' : 0,
    'number'  : 1,
    'date'    : 2,
    'boolean' : 3,
    'text'    : 4
};

//ado数据类型
F.Model.AdoDataType = {
		0:		{ name: "adEmpty", type: 'unknown' },
		10:		{ name: "adError", type: 'unknown' },
		11:		{ name: "adBoolean", type: 'boolean' },
		128:	{ name: "adBinary", type: 'unknown' },
		129:	{ name: "adChar", type: 'text' },
		12:		{ name: "adVariant", type: 'unknown' },
		130:	{ name: "adWChar", type: 'text' },
		131:	{ name: "adNumeric", type: 'number' },
		132:	{ name: "adUserDefined", type: 'unknown' },
		133:	{ name: "adDBDate", type: 'date' },
		134:	{ name: "adDBTime", type: 'date' },
		135:	{ name: "adDBTimeStamp", type: 'date' },
		136:	{ name: "adChapter", type: 'unknown' },
		137:	{ name: "adDBFileTime", type: 'date' },
		138:	{ name: "adPropVariant", type: 'unknown' },
		139:	{ name: "adVarNumeric", type: 'number' },
		13:		{ name: "adIUnknown", type: 'unknown' },
		14:		{ name: "adDecimal", type: 'number' },
		16:		{ name: "adTinyInt", type: 'number' },
		17:		{ name: "adUnsignedTinyInt", type: 'number' },
		18:		{ name: "adUnsignedSmallInt", type: 'number' },
		19:		{ name: "adUnsignedInt", type: 'number' },
		200:	{ name: "adVarChar", type: 'text' },
		201:	{ name: "adLongVarChar", type: 'text' },
		202:	{ name: "adVarWChar", type: 'text' },
		203:	{ name: "adLongVarWChar", type: 'text' },
		204:	{ name: "adVarBinary", type: 'unknown' },
		205:	{ name: "adLongVarBinary", type: 'unknown' },
		20:		{ name: "adBigInt", type: 'number' },
		21:		{ name: "adUnsignedBigInt", type: 'number' },
		2:		{ name: "adSmallInt", type: 'number' },
		3:		{ name: "adInteger", type: 'number' },
		4:		{ name: "adSingle", type: 'number' },
		5:		{ name: "adDouble", type: 'number' },
		64:		{ name: "adFileTime", type: 'date' },
		6:		{ name: "adCurrency", type: 'number' },
		72:		{ name: "adGUID", type: 'unknown' },
		7:		{ name: "adDate", type: 'date' },
		8192:	{ name: "adArray", type: 'unknown' },
		8:		{ name: "adBSTR", type: 'unknown' },
		9:		{ name: "adIDispatch", type: 'unknown' }
};

// vim:ft=javascript
%>
