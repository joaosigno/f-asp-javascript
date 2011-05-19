<%
F.namespace('F.controller');

//  /index.asp?r=site&a=xxx
F.controller.site = {
    //首页
    index : function(){
        display('template/index.html');

        var u = new F.Upload();
        u.saveAllTo('upa');
        die();

        assign('page_title', '首页');
        display('template/index.html');
    },

    //列表页
    list:function(){
        //this._checkCache();

        var db = this._openDb();
        var model = db.model('learning');
        var page = model.page(F.get('p'), 10, 'articleid,title');
        db.close();

        assign('page_title', '列表页');
        assign('posts', page.data);
        assign('page_numbers', page.numbers);
        assign('page', page);

        var cache = display('template/list.html');
        F.cache.setFileText(cache);
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
            F.cache.setFileText(cache);
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
        var cacheTime = 1000 * 60 * 60; //1小时
        if(F.cache.existFile()){
            if(new Date() - F.cache.time() < cacheTime){
                echo(F.cache.getFileText());
                //log(new Date() - START);
                die();
            }
        }
    }
};



F.controller.test = {
    index: function(){
        echo('hahahah');
    }
};

// vim:ft=javascript
%>

