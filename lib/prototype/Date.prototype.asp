<%

// thanks: Thomas Kjoernes <thomas@ipv.no>

Date.prototype.getWeek = function() {
    var a = Math.floor((13-(this.getMonth()))/12);
    var y = this.getFullYear()+4800-a;
    var m = (this.getMonth())+(12*a)-2;
    var jd = this.getDate() + Math.floor(((153*m)+2)/5) + (365*y) + Math.floor(y/4) - Math.floor(y/100) + Math.floor(y/400) - 32045;
    var d4 = (jd+31741-(jd%7))%146097%36524%1461;
    var L = Math.floor(d4/1460);
    var d1 = ((d4-L)%365)+L;
    return Math.floor(d1/7)+1;
};

Date.prototype.isLeepYear = function(year) {
    var y = year || this.getFullYear();
    return (y%4===0 && (y%100!==0 || y%400===0)) ? true : false;
};

Date.prototype.format = function(format) {
	if (format) {
		var temp = format.toString();
        temp = temp.replace("YYYY", this.getFullYear().toPaddedString(4))
		.replace("YY", this.getYear().toPaddedString(2))
		.replace("MM", this.getMonth().inc().toPaddedString(2))
		.replace("M", this.getMonth().inc().toString())
		.replace("DD", this.getDate().toPaddedString(2))
		.replace("D", this.getDate().toString())
		.replace("W", this.getWeek())
		.replace("hh", this.getHours().toPaddedString(2))
		.replace("h", this.getHours().toString())
		.replace("mm", this.getMinutes().toPaddedString(2))
		.replace("ss", this.getSeconds().toPaddedString(2))
		.replace("f", this.getMilliseconds().toString());
		return temp;
	}
};

Date.prototype.toString = function() {
	return this.toUTCString();
};

Date.prototype.toISOString = function() {
	return this.format("YYYY-MM-DD hh:mm:ss");
};


// vim:ft=javascript
%>
