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
        this._checkCache();

        var db = this._openDb();
        var model = db.model('learning');

        var posts = model.findAll();
        db.close();

        assign('page_title', '列表页');
        assign('posts', posts);

        var cache = display('template/list.html');
        F.cache.setFile(cache);
    },

    //查看文章
    view : function(){
        this._checkCache();

        var id = parseInt(F.get('id'));
        if(isNaN(id)) die('错误参数');

        var db = this._openDb();
        var model = db.model('learning');

        var post = model.find(id);
        db.close();

        if(!post)
            die('没有此文');
        else{
            assign('page_title', post.title);
            assign('post', post);
            var cache = display('template/view.html');
            F.cache.setFile(cache);
        }
    },

    //编辑文章
    edit : function(){
        var id = parseInt(F.get('id') || F.post('id'));
        if(isNaN(id)) die('错误参数');

        var db = this._openDb();
        var model = db.model('learning');

        if(F.isPost()){
            model.update(id,{
                title: F.post('title'),
                content:F.post('content')
            });
            db.close();
            F.go('/?a=view&id=' + id);
        }else{
            var post = model.find(id);
            db.close();
            if(!post)
                die('没有此文');
            assign('page_title', post.title);
            assign('post', post);
            display('template/edit.html');
        }
    },

    _openDb: function(){
        var db = new F.MsJetConnection('data.mdb').open();
        return db;
    },

    _checkCache: function(){
        if(F.cache.existFile()){
            die(F.cache.getFile());
        }
    }
};

// vim:ft=javascript
%>

