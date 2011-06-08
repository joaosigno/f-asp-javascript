<%

/**
* 框架顶级命名空间
*/
var F = {
    version: 20110520
};

/**
* 当前作用域this指针
*/
F.env = this;

/**
* 获取唯一的id
*/
F.getGuid = function() {
    var _id = 1;
    F.getGuid = function() {
        _id++;
        return _id;
    };
    return _id;
};

/**
* 表示已经引入的命名空间
*/
F._included = {};

/**
* 为给定的参数创建命名空间
*/
F.namespace = function(name) {
    var ns = name.split('.'),
    nt = ns.shift(),
    is_f = nt == 'F' || nt == 'feng',
    g = is_f ? F: (F.env[nt] = {}),
    cur = g,
    part;
    if (is_f) {
        F._included[name] = true;
    }
    while (ns.length && (part = ns.shift())) {
        if (!cur[part]) {
            cur[part] = {};
        }
        cur = cur[part];
    }
};

/**
* 声明需要依赖的“包”，框架根据这些信息将依赖的“包”
* 引入到当前环境中。
*/
F.require = function(name) {
    if (!F._included[name]) {
        //TODO
    }
};

/** 
* 模拟继承，子类可以使用_superClass找到父类
*/
F.inherits = function(fn, parentFn) {
    function tempFn() {};
    tempFn.prototype = parentFn.prototype;
    fn._superClass = parentFn.prototype;
    fn.prototype = new tempFn();
    fn.prototype.constructor = fn;
};

F.isArray = function(arg) {
    return arg instanceof Array || '[object Array]' === Object.prototype.toString.call(arg);
}

F.isObject = function(arg) {
    return 'object' === typeof arg || 'function' === typeof arg;
}

F.isFunction = function(arg) {
    return '[object Function]' === Object.prototype.toString.call(arg);
}

F.isNumber = function(arg) {
    return '[object Number]' === Object.prototype.toString.call(arg);
}

F.isString = function(arg) {
    return '[object String]' === Object.prototype.toString.call(arg);
}

F.isBoolen = function(arg) {
    return 'boolen' === typeof arg;
}

F.isUndefinded = function(arg, u){
    return arg === u;
};

F.extend = function(obj_desc, obj_source) {
    for (var fn in obj_source) {
        obj_desc[fn] = obj_source[fn];
    }
    return obj_desc;
};

F.addMethods = function(obj_methods) {
    F.extend(F, obj_methods);
};

//打印F的结构
F.desc = function(){
    function desc(json, pre){
        var html = ['<ul class="F_DESC">'];
        for(var i in json){
            var key = pre + '.' + (i.indexOf('.') !== -1 ? '&lt;' + i + '&gt;' : i);
            html.push('<li><b>' + key + '</b><span>' + 
                (typeof(json[i]) === 'function' ?
                json[i].toString().match(/function\s*\([^)]*?\)/) || 'function(...)' : typeof json[i]) + 
            '</span></li>');
            if(typeof json[i] === 'object' && json[i] !== this){
                html.push(desc(json[i], key));
            }else if(typeof json[i] === 'function'){
                html.push(desc(json[i].prototype, key + '.prototype'));
            }
        }
        html.push('</ul>');
        return html.join('');
    }
    var style = '<style>.F_DESC b{font:14px/18px Consolas,Monaco,"Courier New"}'+
    '.F_DESC span{color:#0BAD03;font-size:13px;margin-left:10px;}</style>';

    var html = [];    
    Array.prototype.forEach.call(arguments, function(v, i){
        html.push(desc(v[0], v[1]));
    });
    return style + html.join('');
};

////////  asp ////////

//获取url参数
F.get = function(key){
    if(key === undefined){
        var r = {},s = new Enumerator(Request.QueryString);
        for(;!s.atEnd();s.moveNext()){
            var x = s.item();
            r[x] = Request.QueryString(x).Item;
        }
        return r;
    }else{
        return Request.QueryString(key).Item;
    }
};

//获取post参数
F.post = function(key){
    if(key === undefined){
        var r = {},s = new Enumerator(Request.Form);
        for(;!s.atEnd();s.moveNext()){
            var x = s.item();
            r[x] = Request.Form(x).Item;
        }
        return r;
    }else{
        return Request.Form(key).Item;
    }
};

//获取server参数
F.server = function(key){
    if(key === undefined){
        var r = {},s = new Enumerator(Request.ServerVariables);
        for(;!s.atEnd();s.moveNext()){
            var x = s.item();
            r[x] = Request.ServerVariables(x).Item;
        }
        return r;
    }else{
        return Request.ServerVariables(key).Item;
    }
};

//是否是get请求
F.isGet = function(){
    return F.server("REQUEST_METHOD").toLowerCase() === 'get';
};

//是否是post请求
F.isPost = function(){
    return F.server("REQUEST_METHOD").toLowerCase() === 'post';
};

//获取ip地址
F.ip = function(){
    var proxy = F.server("HTTP_X_FORWARDED_FOR"),
    ip = proxy && proxy.indexOf("unknown") != -1 ? proxy.split(/,;/g)[0] : F.server("REMOTE_ADDR");
    ip = ip.trim().substring(0, 15);
    return "::1" === ip ? "127.0.0.1" : ip;
};

//生成guid
F.guid = function(){
    var scriptletTypelib = new ActiveXObject("Scriptlet.Typelib");
    var value = scriptletTypelib.Guid.substring(0,38);
    scriptletTypelib = null;
    return value;
};

//进行html转意
F.encodeHTML = function(text){
    return Server.HTMLEncode(text);
};

//url转向
F.go = function(url){
    Response.Redirect(url);
};

//增加header
F.header = function(key, value){
    Response.AddHeader(key, value);
};

//页面本身url
F.url = function(){
    var port = F.server('SERVER_PORT');
    var server = F.server('SERVER_NAME');
    var url = F.server('URL'), query = F.server('QUERY_STRING');
    return (port == '443' ? 'https://' : 'http://') + server + 
        ((port=="80"||port=="443")?"":":"+port)+url+(query===''?'':'?'+query);
};

//执行脚本
F.execute = function(path){
    var js = new F.File(path).getText();
    try{
        return (new Function(js))();
    }catch(e){
        e.path = path;
        e.js = js;
        debug(arguments, e);
    }
};

// vim:ft=javascript
%>
