<%
F.namespace('F.controller');

//  /index.asp?r=site&a=xxx
F.controller.site = {

    //首页
    index : function(){
        assign('page_title', '首页');
        display('template/index.html');
    },

    //列表页
    list:function(){
        var db = new F.MsJetConnection('data.mdb').open();
        var posts = db.getJson('select top 10 * from learning');
        var m = db.model('learning');
        //log(m.find())
        db.close();
        assign('page_title', '列表页');
        assign('posts', posts);
        display('template/list.html');
    },

    //查看文章
    view : function(){
        var id = parseInt(F.get('id'));
        if(isNaN(id)) die('错误参数');

        var db = new F.MsJetConnection('data.mdb').open();
        var posts = db.getJson('select * from learning where articleid={$id}'.fetch({id:id}));
        db.close();

        if(posts.length == 0)
            die('没有此文');
        else{
            assign('page_title', posts[0].title);
            assign('post', posts[0]);
            display('template/view.html');
        }
    },

    //编辑文章
    edit : function(){
        var id = parseInt(F.get('id') || F.post('id'));
        if(isNaN(id)) die('错误参数');
        var db = new F.MsJetConnection('data.mdb').open();

        if(F.isPost()){
            db.update('select * from learning where articleid={$id}'.fetch({id:id}),{
                title: F.post('title'),
                content:F.post('content')
            });
            db.close();
            F.go('/?a=view&id=' + id);
        }else{
            var posts = db.getJson('select * from learning where articleid={$id}'.fetch({id:id}));
            if(posts.length == 0)
                die('没有此文');
            db.close();
            assign('page_title', posts[0].title);
            assign('post', posts[0]);
            display('template/edit.html');
        }
    },

    _private: function(){
        log('Error to see this');
    }
};

// vim:ft=javascript
%>

