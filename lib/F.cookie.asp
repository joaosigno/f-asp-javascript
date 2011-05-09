<%
/// Cookie操作
F.cookie = {
	
	get : function(name) {
		var cookie = Request.Cookies(name), value;	
		if (cookie.HasKeys) {
			value = {};
			for (var i = 1, len = cookie.Count; i <= len; i++) {
				value[cookie.Key(i)] = cookie.Item(i);
			}
			return value;
		} else {
			return cookie.Item;
		}
	},

	/// 设置Cookie
	/// @param {String} Cookie名
	/// @param {Mixed} Cookie值
	/// @param {Date} 过期时间
	/// @param {String} 域
	/// @param {String} 路径
	/// @param {Boolean} 是否仅把Cookie发送给受保护的服务器(https)
	set : function(name, value, expires, domain, path, secure) {
		if ("string" === typeof value) {
			Response.Cookies(name) = value;
		} else {
			for (var i in value) {
				if (Object.hasOwnProperty.call(value, i)) {
					Response.Cookies(name)(i) = value[i];
				}
			}
		}
		
		if (expires) {
            var date = expires;
            Response.Cookies(name).Expires = (date.getMonth() + 1) +
                '/' + date.getDate() + '/' + date.getFullYear() + ' ' + 
                date.getHours() + ':' + date.getMinutes() + ':' + 
                date.getSeconds();
		}

		domain && (Response.Cookies(name).Domain = domain);
		path && (Response.Cookies(name).Path = path);
		secure && (Response.Cookies(name).Secure = secure);
	},

	/// 删除Cookie
	/// @param {String} Cookie名，省略时为删除全部
	remove : function(name) {
		if (name) {
			Response.Cookies(name).Expires = "8/4/1985";
		} else {
			for (var i = 1, len = Request.Cookies.Count; i <= len; i++) {
				Response.Cookies.Item(i).Expires = "8/4/1985";
			}
		}
	}
};


// vim:ft=javascript
%>
