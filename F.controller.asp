<%
F.namespace('F.controller');


//首页
F.controller.index = function(){
    display('template/index.html');
};


//文章页
F.controller.list = function(){
    var db = new F.MsJetConnection('data.mdb').open();
    var posts = db.getJson('select top 10 * from learning');
    db.close();
    assign('posts', posts);
    display('template/list.html');
};


//查看文章
F.controller.view = function(){
    var id = parseInt(F.get('id'));
    if(isNaN(id)) die('错误参数');

    var db = new F.MsJetConnection('data.mdb').open();
    var posts = db.getJson('select * from learning where articleid={$id}'.fetch({id:id}));
    db.close();

    if(posts.length == 0)
        die('没有此文');
    else{
        assign('post', posts[0]);
        display('template/view.html');
    }

};

// vim:ft=javascript
%>

