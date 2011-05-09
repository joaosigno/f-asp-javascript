<%
//WF开始
function WF(key){return Request(key);};

//封闭作用域
(function(){
//直接拷贝了jQuery的entend方法，和一些常用方法
var toString = Object.prototype.toString,
    hasOwnProperty = Object.prototype.hasOwnProperty;

WF.extend = WF.prototype.extend = function() {
	// copy reference to target object
	var target = arguments[0] || {}, i = 1, length = arguments.length, deep = false, options, name, src, copy;
 
	// Handle a deep copy situation
	if ( typeof target === "boolean" ) {
		deep = target;
		target = arguments[1] || {};
		// skip the boolean and the target
		i = 2;
	}
 
	// Handle case when target is a string or something (possible in deep copy)
	if ( typeof target !== "object" && !WF.isFunction(target) ) {
		target = {};
	}
 
	// extend WF itself if only one argument is passed
	if ( length === i ) {
		target = this;
		--i;
	}
 
	for ( ; i < length; i++ ) {
		// Only deal with non-null/undefined values
		if ( (options = arguments[ i ]) != null ) {
			// Extend the base object
			for ( name in options ) {
				src = target[ name ];
				copy = options[ name ];
 
				// Prevent never-ending loop
				if ( target === copy ) {
					continue;
				}
 
				// Recurse if we're merging object literal values or arrays
				if ( deep && copy && ( WF.isPlainObject(copy) || WF.isArray(copy) ) ) {
					var clone = src && ( WF.isPlainObject(src) || WF.isArray(src) ) ? src
						: WF.isArray(copy) ? [] : {};
 
					// Never move original objects, clone them
					target[ name ] = WF.extend( deep, clone, copy );
 
				// Don't bring in undefined values
				} else if ( copy !== undefined ) {
					target[ name ] = copy;
				}
			}
		}
	}
 
	// Return the modified object
	return target;
};

WF.extend({
    isFunction: function( obj ) {
		return toString.call(obj) === "[object Function]";
	},
 
	isArray: function( obj ) {
		return toString.call(obj) === "[object Array]";
	},
    
    isUndefined: function(obj){
        if(typeof obj === 'undefined')
            return true;
        if(typeof obj === 'object' && (obj + '' === 'undefined'))
            return true;
        return false;
    },
 
	isPlainObject: function( obj ) {
		if ( !obj || toString.call(obj) !== "[object Object]" || obj.nodeType || obj.setInterval ) {
			return false;
		}
		
		// Not own constructor property must be Object
		if ( obj.constructor
			&& !hasOwnProperty.call(obj, "constructor")
			&& !hasOwnProperty.call(obj.constructor.prototype, "isPrototypeOf") ) {
			return false;
		}
		
		// Own properties are enumerated firstly, so to speed up,
		// if last one is own, then all properties are own.
	
		var key;
		for ( key in obj ) {}
		
		return key === undefined || hasOwnProperty.call( obj, key );
	},
 
	isEmptyObject: function( obj ) {
		for ( var name in obj ) {
			return false;
		}
		return true;
	},
    
    trim: function( text ) {
		return (text || "").replace( /^(\s|\u00A0)+|(\s|\u00A0)+$/g , "" );
	},
    
    each: function( object, callback, args ) {
		var name, i = 0,
			length = object.length,
			isObj = length === undefined || WF.isFunction(object);
 
		if ( args ) {
			if ( isObj ) {
				for ( name in object ) {
					if ( callback.apply( object[ name ], args ) === false ) {
						break;
					}
				}
			} else {
				for ( ; i < length; ) {
					if ( callback.apply( object[ i++ ], args ) === false ) {
						break;
					}
				}
			}
 
		// A special, fast, case for the most common use of each
		} else {
			if ( isObj ) {
				for ( name in object ) {
					if ( callback.call( object[ name ], name, object[ name ] ) === false ) {
						break;
					}
				}
			} else {
				for ( var value = object[0];
					i < length && callback.call( value, i, value ) !== false; value = object[++i] ) {}
			}
		}
	}
});

//jQuery 抄袭结束


//封装get,post, server参数, ip等常用操作
WF.extend({
    get: function(key){
        return Request.QueryString(key);
    },
    
    post: function(key){
        return Request.Form(key);
    },
    
    server: function(key){
        return Request.ServerVariables(key);
    },
    
    ip: function(){
        var proxy = WF.server("HTTP_X_FORWARDED_FOR"),
		ip = proxy && proxy.indexOf("unknown") != -1 ? proxy.split(/,;/g)[0] : WF.server("REMOTE_ADDR");
        ip = WF.trim(ip).substring(0, 15);
        return "::1" === ip ? "127.0.0.1" : ip;
    },
    
    guid: function(){
        var scriptletTypelib = new ActiveXObject("Scriptlet.Typelib");
        var value = scriptletTypelib.Guid.substring(0,38);
        scriptletTypelib = null;
        return value;
    }
});


/// Session操作
WF.session = {
	get : function(name) {
		return Session(name);
	},
	
	set : function(name, value) {
		Session(name) = value;
	},

	remove : function(name) {
		if (name) {
			Session.Contents.Remove(name);
		} else {
			Session.Contents.RemoveAll();
		}
	}
};


/// 缓存操作
WF.cache = {
	set : function(name, value) {
		Application.Lock();
		Application(name) = value;
		Application.UnLock();
	},
	
	get : function(name) {
		var value = Application(name);
		return value;
	},
	
	remove : function(name) {
		Application.Lock();
		if (name) {
			Application.Contents.Remove(name);
		} else {
			Application.Contents.RemoveAll();
		}
		Application.UnLock();
	}
};


//ajax相关，用于服务器端取数据
function xml_http(){
    var xv = [".6.0", ".5.0", ".4.0", ".3.0", ".2.6", ""];
    for (var i = 0; i < xv.length; i++) {
        try {
            return new ActiveXObject("msxml2.xmlHttp" + xv[i]);
        } catch (ex) { }
    }
    return false;
}

WF.ajax = {
    load: function(method, url, fn, type, data){
        var http = xml_http();
        http.onreadystatechange = function(){
            //log(http.readyState);
            if(http.readyState == 4 && http.status === 200){
                var types = {
                    'xml' : 'responseXML',
                    'text' : 'responseText',
                    'body' : 'responseBody',
                    'stream' : 'responseStream'
                };
                type = type || 'text';
                fn(http[types[type]]);
                http = null;
            }
        }
        
        http.open(method, url, false);
        http.send(data ? data : null);
    },

    get: function(url, fn, type){
        WF.ajax.load('get', url, fn, type);
    }
};


//文件操作
WF.file = {
	path:Server.MapPath(".")+"\\",
	fso:new ActiveXObject("Scripting.FileSystemObject"),
    
    //预览文件内容
	view:function(filename,mode){
		var f = this.fso.OpenTextFile(Server.MapPath(filename),mode||1);
		print("<pre>");
		while(!f.AtEndOfStream)
		{
			print(f.ReadLine(), '\n');
		}
		print("</pre>");
		f.Close();
	},
    
    //判断一个文件是否存在
	exists:function(filename){
		return this.fso.FileExists(this.path+filename);
	},
    
    //获取文件内容，使用默认编码
	get:function(filename){
		var f = this.fso.OpenTextFile(Server.MapPath(filename),1);
		var s = "";
		while(!f.AtEndOfStream)
		{
			s+=f.ReadLine()+"\n";
		}
		f.Close();
		return s;
	},
    
    //设置文件内容
	set:function(filename,text){
		var f = this.fso.OpenTextFile(this.path+filename,2,true);
		f.Write(text);
		f.Close();
	},
	move:function(o,n){
		
	},
    
    //删除文件或目录
	del:function(filename){
		if(this.has(filename)) this.fso.DeleteFile(this.path+filename);
	},
    
    //获取目录文件列表
	files:function(dir){
		dir = dir||"";
		var f, fc, s;
		f = this.fso.GetFolder(this.path+dir);
		fc = new Enumerator(f.files);
		s = [];
		for (; !fc.atEnd(); fc.moveNext())
		{
		   s.push(this.fso.GetFileName(fc.item()));
		}
		return(s);
	},
    
    //获取文件编码
    getCharset: function(path){
        var path = String(path), sContent = "";
        if (path.indexOf(":") == -1) { path = Server.MapPath(path); }
        var str = WF.file.readTextFile(path, 'iso-8859-15', 4);
        var charset, 
            s1 = str.substr(0, 3), 
            s2 = str.substr(0, 2);
        if (s1 == "\xEF\xBB\xBF") { charset = "utf-8"; }
        else if (s2 == "\xFF\xFE") { charset = "utf-16le"; }
        else if (s2 == "\xFE\xFF") { charset = "utf-16be"; }
        else if (s2 == "\x84\x31\x95\x33") { charset = "gb18030"; }
        else { charset = "gbk"; }
        return charset;
    },
    
    //读取文件内容，可以根据编码读取一定长度的内容
    readTextFile: function(path, charset, length){
        if (path.indexOf(":") == -1) { 
            path = Server.MapPath(path); 
        }
        var s = Server.CreateObject("adodb.stream");
        s.Type = 2;
        s.Mode = 3;
        s.CharSet = charset || "iso-8859-15";
        s.Open();
        s.LoadFromFile(path);
        var str;
        if(length){
            str = s.ReadText(length);
        }else{
            str = s.ReadText();
        }
        s.Close();
        s = null;
        return str;
    },
    
    //能够自动判断编码读取文件
    autoLoadTextFile: function(path) {
        var charset = WF.file.getCharset(path);
        sContent = WF.file.readTextFile(path, charset);
        return sContent;
    },
    
    include : function(fPath) {
        var sContent = WF.file.autoLoadTextFile(fPath);
        sContent = sContent.replace(/(\x3C%\s*@)([\s\S]*?)(%\x3E)/gm, "")
                   .replace(/(<\!--\s*#include\s*file\s*=\s*)([\s\S]*?)(\s*-->)/gi, "")
                   .replace(/(<\!script\s*[\s\S]*?\s*runat\s*=\s*"server"\s*>)([\s\S]*?)(<\/script>)/gi, "<\%" + sContent + "%\>")
                   .replace(/(\x3C%\s*=)([\s\S]*?)(%\x3E)/gm, "<\%Response.Write($2);%\>");
        sContent = ("%\>" + sContent + "<\%").replace(/(%\x3E)([\s\S]*?)(\x3C%)/gm, __encode);
        with (this) { eval(sContent); }
        function __encode() {
            var s = arguments[2];
            if (!s) { return ""; }
            s = s.replace(/\\/g, "\\\\")
                .replace(/[\x27\x22]/gm, "\\$&")
                .replace(/\n/mg, "\\n")
                .replace(/\r/mg, "\\r")
                .replace(/\t/mg, "\\t");
            return "\nResponse.Write(\"" + s + "\");\n";
        }
    }
};

WF.include = WF.file.include;



//--- xml处理 ---

//根据url获取xml
function parseURL(url) {
	var xmlDOM = new ActiveXObject("Microsoft.XMLDOM");
	xmlDOM.async = false;
	xmlDOM.validateOnParse = false;
	var success = xmlDOM.load(url);
	if (!success) {
        WF.ajax.load('GET', url, function(text){
            success = xmlDOM.loadXML(text);
        }, 'text');
	}
	if(success){
        return xmlDOM.documentElement;
    }
	return {};
}

//将xml字符串变成xml对象
function parseXMLString(xmlString) {
	var xmlDOM = new ActiveXObject("Microsoft.XMLDOM");
	xmlDOM.async = false;
	xmlDOM.validateOnParse = false;
	var success = xmlDOM.loadXML(xmlString);
	if(success){
        return xmlDOM.documentElement;
    }
	return {};
}

//
function toXMLString(xml){
    if(typeof xml == 'object' && ('xml' in xml)){
       return xml.xml;
    }
    return '';
}

//WF.xml

WF.xml = {
    parse : parseURL,
    parseURL : parseURL,
    parseString : parseXMLString,
    xmlString : toXMLString
};

//封闭结束
})();








//test
/*

function xml_text(xml, tag){
    var t = xml.getElementsByTagName(tag)[0];
    return t ? t.text : '';
}
WF.ajax.get('http://news.baidu.com/n?cmd=1&class=internet&tn=rss', function(data){
    var xml = data;
    WF.file.set('xxx', data);
    var items = xml.getElementsByTagName('item');
    WF.each(items, function(i, item){
        log(xml_text(item, 'title'));
        log(xml_text(item, 'description'));
    });
},'text');


WF.ajax.get('hash.js', function(data){
    log(data)
});


print(WF.file.autoLoadTextFile('hash.js'));
WF.include('a.txt');

*/

%>
