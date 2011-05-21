<%
//文件夹类
F.Folder = function(path){
    this.path = '';
    this.fso = new ActiveXObject("Scripting.FileSystemObject");
    if(F.isString(path)){
        this.setPath(path);
    }
};


F.Folder.prototype = {

    //设置路径
    setPath: function(path){
        this.path = (path.indexOf(':') > -1) ? path : Server.MapPath(path);
    },

    //返回路径
    getPath: function(){
        return this.path;
    },

    //是否存在
    exist: function(path){
        return this.fso.FolderExists(path || this.path);
    },

    //根据路径递归创建
    create: function(path){
        var ps = (this.path || path).split(':');
        var fs = ps[1].split(/\\|\//);
        var tmp = ps[0] + ':';
        do{
            tmp += '\\' + fs.shift();
            if(!this.exist(tmp)){
                this.fso.CreateFolder(tmp);
            }
        }while(fs.length && fs[0])
    },

    //删除路径
    remove: function(path){
        if(this.exist(path)){
            this.fso.DeleteFolder(this.path || path);
        }
    },

    //销毁示例资源
    dispose: function(){
        this.fso = null;
        this.path = null;
    }
};




// vim:ft=javascript
%>
