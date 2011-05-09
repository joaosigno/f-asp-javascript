<%

/// Session操作
F.session = {
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


// vim:ft=javascript
%>
