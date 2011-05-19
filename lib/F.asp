<%

/**
* 框架顶级命名空间
*/
var F = {
	version: 20110419
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

F.isUndefinded = function(arg){
    var undefined;
    return arg === undefined;
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

///////// 文本处理 ///////

F.trim = function(text){
    return (text || "").replace( /^(\s|\u00A0)+|(\s|\u00A0)+$/g , "" );
};

////////  asp ////////

//获取url参数
F.get = function(key){
    return Request.QueryString(key).Item;
};

//获取post参数
F.post = function(key){
    return Request.Form(key).Item;
};

//获取server参数
F.server = function(key){
    return Request.ServerVariables(key).Item;
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
    ip = F.trim(ip).substring(0, 15);
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

// vim:ft=javascript
%>