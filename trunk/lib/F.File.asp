<%
//文件类
F.File = function(filename){
    this.path = '';
    if(F.isString(filename)){
        this.setPath(filename);
    }
    if(!F.File.fso){
        F.File.fso = new ActiveXObject("Scripting.FileSystemObject");
    }
    this.fso = F.File.fso;
};

//全局变量，所有实例共用
F.File.fso = null;

F.File.prototype = {
    //取得文件名
    getFileName: function(){
        return this.fso.GetFileName(this.path);
    },

    //文件类型
    getFileType: function(){
        if(!this.exist()){
			debug(arguments, this);
        }
        var o = new ActiveXObject("ADODB.Stream")
        o.Type = 2;
        o.Mode = 3;
        o.CharSet = 'iso-8859-15';
        o.Open();
        o.LoadFromFile(this.path);
        o.Position = 0;
        var s = o.ReadText(20), t = {}, pid = "";
        o.Close();
        o = null;
        if ((pid = s.substr(0, 2)) == "BM") {
            t.type = "bmp";
        } else if (pid == "MZ") {
            t.type = "exe"; t.format = "pe";
        } else if (pid == "PK") {
            t.type = "zip";
        } else if ((pid = s.substr(0, 3)) == "GIF") {
            t.type = "gif";
        } else if (pid == "II*") {
            t.type = "tif";
        } else if (pid == "CWS" || pid == "FWS") {
            t.type = "swf"; t.format = pid.toLowerCase();
        } else if (pid == "ID3") {
            t.type = "mp3";
        } else if ((pid = s.substr(0, 4)) == "\x89PNG") {
            t.type = "png";
        } else if (pid == "RIFF") {
            t.type = "wav";
        } else if (pid == "ITSF") {
            t.type = "chm";
        } else if (pid == "\x25PDF") {
            t.type = "pdf";
        } else if (pid == "Rar\x21") {
            t.type = "rar";
        } else if (s.substr(6, 4) == "JFIF") {
            t.type = "jpg"; t.format = "jfif";
        } else if (pid == "\xFF\xD8\xFF\xE1") {
            t.type = "jpg";
        } else if (pid == ".RMF") {
            t.type = "rm";
        } else if (pid == "0\x26\xB2u") {
            t.type = "wma";
        } else if (s.substr(4, 12) == "Standard Jet") {
            t.type = "mdb";
        } else if (s.substr(0, 12) == "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1\x00\x00\x00\x00") {
            t.type = "mso";
        } else if (s.substr(2, 3) == "AMR") {
            t.type = "amr";
        } else if (s.substr(0, 3) == "\xEF\xBB\xBF") {
            t.type = "txt"; t.format = "utf-8";
        } else if ((pid = s.substr(0, 2)) == "\xFF\xFE") {
            t.type = "txt"; t.format = "utf-16le";
        } else if (pid == "\xFE\xFF") {
            t.type = "txt"; t.format = "utf-16be";
        } else if (s.substr(0, 4) == "\x84\x31\x95\x33") {
            t.type = "txt"; t.format = "gb18030";
        } else {
            t.type = "unkonwn";
        }
        return t;
    },

    getText: function(charset){
        if(!this.exist()){
			debug(arguments, this);
        }
        var s = new ActiveXObject("ADODB.Stream"), str;
        s.Type = 2;
        s.CharSet = charset || 'utf-8';
        s.Open();
        s.LoadFromFile(this.path);
        str = s.ReadText();
        s.Close();
        s = null;
        return str;
    },

    getBinary: function(){
        if(!this.exist()){
			debug(arguments, this);
        }
        var content;
        var s = new ActiveXObject("ADODB.Stream");
        s.Type = 1;
        s.Open();
        s.LoadFromFile(this.path);
        content = s.Read();
        s.Close();
        s = null;
        return content;
    },

    getBase64String: function(){
        var xml = new ActiveXObject('Microsoft.XMLDOM');
        xml.loadXML('<r xmlns:dt="urn:schemas-microsoft-com:datatypes"><e dt:dt="bin.base64"></e></r>');
        var f = xml.documentElement.selectSingleNode('e');
        f.nodeTypedValue = this.getBinary();
        return f.text;
    },

    setText: function(text, charset){
        var s = new ActiveXObject("ADODB.Stream");
        s.Type = 2;
        s.Charset = charset || 'utf-8';
        s.Open();
        s.WriteText(text);
        s.SaveToFile(this.path, 2);
        s.Close();
        s = null;
        return this;
    },

    setBinary: function(content){
        var s = new ActiveXObject("ADODB.Stream");
        s.Type = 1;
        s.Open();
        s.Write(content);
        s.SaveToFile(this.path, 2);
        s.Close();
        s = null;
        return this;
    },

    setBase64String: function(str64){
        var xml = new ActiveXObject('Microsoft.XMLDOM');
        xml.loadXML('<r xmlns:dt="urn:schemas-microsoft-com:datatypes"><e dt:dt="bin.base64"></e></r>');
        var f = xml.documentElement.selectSingleNode('e');
        f.text = str64;
        this.setBinary(f.nodeTypedValue);
        f = null;
        xml = null;
        return this;
    },

    //创建文件
    create: function(content){
        var folder = this.getFolder();
        if(!folder.exist()){
            folder.create();
        }
        var f = this.fso.CreateTextFile(this.path, true);
        if(content !== undefined){
            f.WriteLine(content);
        }
        f.Close();
        return this;
    },

    //返回 F.Folder()实例
    getFolder: function(){
        return new F.Folder(this.path.replace(/(\\|\/)[^\\\/]+$/, ''));
    },

    //向文本文件中追加文本。只适合小文件
    appendText: function(text, charset){
        var content = this.getText();
        return this.setText(content + text, charset);
    },

    //设置路径
    setPath: function(path){
        this.path = (path.indexOf(':') > -1) ? path : Server.MapPath(path);
        return this;
    },

    //是否存在
    exist: function(path){
        return this.fso.FileExists(path || this.path);
    },

    //删除文件，如果传入path，path最后可以是通配符
    remove: function(path){
        this.fso.DeleteFile(path || this.path, true);
        return this;
    },

    //获取扩展名
    getExtensionName: function(path){
        return this.fso.GetExtensionName(path || this.path);
    },

    dispose: function(){
        this.path = null;
    }
};

// vim:ft=javascript
%>