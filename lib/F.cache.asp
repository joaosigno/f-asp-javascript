<%
F.namespace('F.cache');
/// 缓存操作

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

// vim:ft=javascript
%>
