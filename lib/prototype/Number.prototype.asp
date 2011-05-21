<%

/* thanks: Thomas Kjoernes <thomas@ipv.no> */

// toPaddedString()
Number.prototype.toPaddedString = function(length, radix, pad) {
	var temp = this.toString(radix ? radix : 10);
	var pad = pad || "0";
	while (temp.length < length) {
		temp = pad + temp;
	}
	return temp;
};

// int()
Number.prototype.int = function(value) {
	if (typeof value === "undefined") value = this.valueOf();
	if (value>0x7FFFFFFF) {
		if (value>0xFFFFFFFF) {
			return NaN;
		} else {
			return 0-((~value)+1);
		}
	} else {
		if (value<0) {
			return NaN;
		} else {
			return value;
		}
	}
}

// uint()
Number.prototype.uint = function(value) {
	if (typeof value === "undefined") value = this.valueOf();
	if (value<0) {
		if (value<-2147483648) {
			return NaN;
		} else {
			return (value+0xFFFFFFFF+1);
		}
	} else {
		if (value>0xFFFFFFFF) {
			return NaN;
		} else {
			return value;
		}
	}
}

// inc()
Number.prototype.inc = function(value) {
	return this.valueOf() + (value ? value : 1);
};

// dec()
Number.prototype.dec = function(value) {
	return this.valueOf() - (value ? value : 1);
};

// and()
Number.prototype.and = function(value) {
	return this.valueOf() & value;
};

// xor()
Number.prototype.xor = function(value) {
	return this.valueOf() ^ value;
};

// or()
Number.prototype.or = function(value) {
	return this.valueOf() | value;
};

// not()
Number.prototype.not = function(value) {
	return ~this.valueOf();
};

// shl()
Number.prototype.shl = function(value) {
	return this.valueOf() << value;
};

// sar()
Number.prototype.sar = function(value) {
	return this.valueOf() >> value;
};

// shr()
Number.prototype.shr = function(value) {
	return this.valueOf() >>> value;
};

// vim:ft=javascript
%>
