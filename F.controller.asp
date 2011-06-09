<%
F.namespace('F.controller');

DEBUG_MODE = true;

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
        var model = db.model('jokes');
        var page = model.page(F.get('p'), 'id,title', 10);
        db.close();

        assign('page_title', '列表页');
        assign('posts', page.data);
        assign('page_numbers', page.numbers);
        assign('page', page);

        var cache = display('template/list.html');
        this._setCache(cache);
    },

    //查看文章
    view : function(){
        //this._checkCache();

        var id = parseInt(F.get('id'));
        if(isNaN(id)) die('错误参数');

        var db = this._openDb();
        var model = db.model('jokes');

        var post = model.find(id);
        db.close();

        if(!post)
            die('没有此文');
        else{
            assign('page_title', post.title);
            assign('post', post);
            var cache = display('template/view.html');
            this._setCache(cache);
        }
    },

    //编辑文章
    edit : function(){
        var id = parseInt(F.get('id') || F.post('id'));
        if(isNaN(id)) die('错误参数');

        var db = this._openDb();
        var model = db.model('jokes');

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

    _init: function(){
        var s = 'r'+F.get('r')+'a'+F.get('a')+'id'+F.get('id')+'p'+F.get('p');
        this._key = F.md5(s);
    },

    _openDb: function(){
        var db = new F.MsJetConnection('data.mdb').open();
        return db;
    },

    _checkCache: function(){
        var cacheTime = 1000 * 60 * 60; //1小时
        if(F.cache.existFile(this._key)){
            if(new Date() - F.cache.time(this._key) < cacheTime){
                echo(F.cache.getFileText(this._key));
                die();
            }
        }
    },

    _setCache: function(content){
        F.cache.setFileText(this._key, content);
    }
};

//用于测试
F.controller.test = {
    index: function(){
        echo(F.desc([F, 'F'], 
            [Array.prototype, 'Array.prototype'], 
            [String.prototype, 'String.prototype'], 
            [Date.prototype, 'Date.prototype'],
            [Number.prototype, 'Number.prototype']));
    },

    markdown: function(){
        echo(F.string.markdown.toHTML('# h1\n\n### h3\nhahaha'));
    }
};

// vim:ft=javascript
%>

