<%
// 缓存操作
F.namespace('F.cache');

F.cache.set = function(name, value) {
    Application.Lock();
    Application(name) = value;
    Application.UnLock();
};

F.cache.get = function(name) {
    var value = Application(name);
    return value;
};

F.cache.remove = function(name) {
    Application.Lock();
    if (name) {
        Application.Contents.Remove(name);
    } else {
        Application.Contents.RemoveAll();
    }
    Application.UnLock();
};

//缓存目录
F.cache._path = 'cache';

//缓存文件对象
F.cache._file = null;

//获得缓存的文件内容
F.cache.getFile = function(){
    var file = this._getFileObject();
    if(file.exist()){
        return file.getText();
    }
    return null;
};

//设置缓存
F.cache.setFile = function(html){
    var file = this._getFileObject();
    file.setText(html);
};

//删除缓存
F.cache.removeFile = function(){
    var file = this._getFileObject();
    file.remove();
};

//是否存在文件缓存
F.cache.existFile = function(){
    var file = this._getFileObject();
    return file.exist();
};

//删除所有缓存文件
F.cache.removeAllFiles = function(){
    var file = new F.File();
    file.fso.DeleteFolder(server.MapPath(F.cache._path), true);
    file.fso.CreateFolder(server.MapPath(F.cache._path));
};

//获取文件对象
F.cache._getFileObject = function(){
    if(!this._file){
        var fileKey = F.string.base64Encode(F.server('QUERY_STRING'));
        this._file = new F.File(F.cache._path + '/' + fileKey);
    }
    return this._file;
};

// vim:ft=javascript
%>
