<%
F.namespace('F.session');
/// Session操作
F.session.get = function(name) {
    return Session(name);
};

F.session.set = function(name, value) {
    Session(name) = value;
};

F.session.remove = function(name) {
    if (name) {
        Session.Contents.Remove(name);
    } else {
        Session.Contents.RemoveAll();
    }
};


// vim:ft=javascript
%>
