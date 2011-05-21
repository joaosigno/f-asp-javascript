<%

/* thanks: Thomas Kjoernes <thomas@ipv.no> */

// isNumber()
String.prototype.isNumber = function() {
    return (/^\d+$/).test(this.valueOf());
};

// padL()
String.prototype.padL = function(length, pad) {
    var temp = this.valueOf();
    var pad = pad || " ";
    while (temp.length<length) {
        temp = pad + temp;
    }
    return temp;
};

// padR()
String.prototype.padR = function(length, pad) {
    var temp = this.valueOf();
    var pad = pad || " ";
    while (temp.length<length) {
        temp = temp + pad;
    }
    return temp;
};

// trim()
String.prototype.trim = function() {
    return this.replace(/^(\s|\u00A0)+|(\s|\u00A0)+$/g , "");
};

// trimL()
String.prototype.trimL = function() {
    return this.replace(/^[\s]+/g, "");
};

// trimR()
String.prototype.trimR = function() {
    return this.replace(/[\s]+$/g, "");
};

// random()
String.prototype.random = function(length, chars) {
    var temp = [];
    var chars = chars || this.valueOf() || "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (var i=0; i<length; i++) {
        var n = Math.floor(Math.random() * chars.length);
        temp.push(chars.charAt(n));
    }
    return temp.join("");
};

// compare()
String.prototype.compare = function(text) {
    return new RegExp("^" + text.replace(/([\\\^\$+[\]{}.=!:(|)])/g, "\\$1").replace(/\*/g, ".*").replace(/\?/g, ".") + "$").test(this);
};

// capitalize()
String.prototype.capitalize = function() {
    return this.substring(0,1).toUpperCase() + this.substring(1);
};

// capitalize()
String.prototype.titelize = function() {
    var a = this.toLowerCase();
    var b = [];
    function isSeparator(c) {
        switch (c) {
        case " " :
        case "." :
        case "," :
        case ";" :
        case "-" :
        case "_" : return true;
        }
    }
    for (var i=0; i<a.length; i++) {
        var c = a.charAt(i);
        var d = a.charAt(i-1);
        if (i===0 || isSeparator(d)) c = c.toUpperCase();
        b.push(c);
    }
    return b.join("");
};

// highlight()
String.prototype.highlight = function(text, prefix, suffix) {
    var perfix = prefix || "<samp>";
    var perfix = suffix || "</samp>";
    var a = this.valueOf();
    var b = this.toLowerCase().split(text.toLowerCase());
    var c = [];
    var j = 0;
    var k = text.length;
    for (var i=0; i<b.length; i++) {
        var l = b[i].length;
        c.push(a.substring(j,j+l) + prefix + a.substring(j+l, j+l+k) + suffix);
        j += (l+k);
    }
    return c.join("");
};

// format()
String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{\s*(.+?)\s*}/g, function(str, arg) { var temp = args[arg]; return (typeof temp === "function") ? temp() : temp; });
};


// vim:ft=javascript
%>
