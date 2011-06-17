<%
F.namespace('F.controller');

DEBUG_MODE = false;

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
        echo(F.markdown('\t:::html\tvare aa \t asdasd'));
    }
};


//博客
F.controller.site = F.controller.blog = {
    _db: function(){
        if(this.__db){
            return this.__db;
        }
        this.__db = new F.MsJetConnection(F.config.dataPath).open();
        return this.__db;
    },

    _init: function(){
        assign('is_home', ACTION === 'index');
        assign('is_view', ACTION === 'view');
        assign('is_add', ACTION === 'add');
        assign('is_edit', ACTION === 'edit');
        assign('is_login', F.User.isLogin());
    },

    _TEXT_TYPE:{
        MAKRDOWN: 1,
        OLD:0,
        HTML:2
    },

    //首页
    index: function(){
        var list = F.cache.get('list');
        if(list){
            list = F.json.parse(list);
        }else{
            var db = this._db();
            var model = db.model('posts');
            list = model.findAll('', 'id, title,create_time', 'id desc');
            db.close();
            F.cache.set('list', F.json.stringify(list));
        }
        assign('list', list);
        assign('page_title', 'WiFeng Blog');
        display('template/blog/index.html');
    },

    //文章查看
    view: function(){
        var id = parseInt(F.get('id')) || 0;
        var post = F.cache.get(id);
        if(post){
            post = F.json.parse(post);
        }else{
            var db = this._db();
            var model = db.model('posts');
            post = model.find('id='+id);
            db.close();
            if(!post){
                die('no post');
            }
            F.cache.set(id, F.json.stringify(post));
        }

        //如果是markdown语法
        if(post.text_type === this._TEXT_TYPE.MAKRDOWN){
            post.content = F.markdown(post.content);
        }
        //以前的blog数据
        else{
            post.content = post.content.replace(/<pre(\w|\W)+?>((\w|\W)+?)<\/pre>/g, function(a, b, c){
                return '<pre>' + F.encodeHTML(c) + '</pre>';
            });

            var index = post.content.indexOf('<pre');
            if(index === -1){
                post.content = post.content.replace(/\n/g, '<br>');
            }else{
                var start = 0;
                while(index !== -1){
                    var p1 = post.content.slice(start, index).replace(/(\r?\n)+/g, '<br>');
                    post.content = post.content.slice(0, start) + p1 + post.content.slice(index);
                    start = post.content.indexOf('</pre>', index + 1);
                    index = post.content.indexOf('<pre', start);
                }
            }
        }
        assign('post', post);
        assign('page_title', post.title);
        display('template/blog/view.html');
    }
};


//管理员部分
F.controller.admin = {
    _init: function(){
        F.controller.blog._init();
        if(ACTION !== 'login'){
            if(!F.User.isLogin()){
                F.go('/?r=admin&a=login');
            }
        }
    },

    _db: function(){
        return F.controller.blog._db();
    },

    _TEXT_TYPE : F.controller.blog._TEXT_TYPE,

    login: function(userName){
        assign('error', '');
        if(F.isGet()){
            assign('page_title', '用户登录');
            display('template/blog/login.html');
        }else{
            var name = F.post('name');
            var password = F.post('password');
            if(name !== "" && password !== ""){
                var db = this._db();
                var user = new F.User();
                if(user.checkLogin(name, password, true)){
                    db.close();
                    F.go('/?r=admin&a=add');
                }
                db.close();
            }
            assign('error', '用户名或密码不正确');
            display('template/blog/login.html');
        }
    },

    logout: function(){
        if(F.User.isLogin()){
            F.User.logout();
        }
        F.go('/?r=blog');
    },

    add: function(){
        var me = this;
        if(F.isGet()){
            display('template/blog/add.html');
        }else{
            var title = F.post('title');
            var content = F.post('content');
            if(!title || !content){
                die('缺少标题或内容');
            }else{
                var db = this._db();
                var model = db.model('posts');
                model.insert({
                    title       : title,
                    content     : content,
                    author      : 'WiFeng',
                    create_time : parseInt(new Date().getTime()/1000),
                    text_type   : me._TEXT_TYPE.MAKRDOWN
                });
                var post = model.find('','id','id desc');
                db.close();
                F.cache.remove();
                F.go('/?r=blog&a=view&id=' + post.id);
            }
        }
    },

    edit: function(){
        var id = parseInt(F.get('id'));
        if(isNaN(id)){
            die('参数无效。');
        }
        var db = this._db();
        var model = db.model('posts');
        var post = model.find('id=' + id);
        if(!post){
            die('没有这篇文章');
        }
        if(F.isGet()){
            assign('post', post);
            db.close();
            display('template/blog/add.html');
        }else{
            delete post.id;//因为id是主键，所以不能更新此字段
            post.title = F.post('title');
            post.content = F.post('content');
            post.update_time = parseInt(new Date().getTime()/1000);
            if(!post.view_number){
                post.view_number = 0;
            }
            post.text_type = this._TEXT_TYPE.MAKRDOWN;
            model.update('id=' + id, post);
            db.close();
            F.cache.remove();
            F.go('/?r=blog&a=view&id=' + id);
        }
    },

    repair: function(){
        var f = new F.File(F.config.dataPath);
        echo('<p>压缩前字节数：' + f.getSize());
        try{
            this._db().repair();
        }catch(e){
            die(e.message);
        }
        echo('<p>修复数据完成');
        echo('<p>压缩后字节数：' + f.getSize());
    },

    x: function(){
        die('ok');
        var me = this;
        var db = this._db();
        var model = db.model('posts');
        var data = new F.File('data.xml').getText();
        var titles = data.match(/<title>(\w|\W)+?<\/title>/g);
        titles.forEach(function(t, i){
            titles[i] = t.replace('<title>', '').replace('</title>', '');
        });
        titles.shift();
        //log(titles)

        var contents = data.match(/<content:encoded><\!\[CDATA\[(\w|\W)+?\]\]/g);
        contents.forEach(function(v, i){
            contents[i] = v.slice(26).slice(0, -2);
        });
        //log(contents);

        var dates = data.match(/<pubDate>(\w|\W)+?<\/pubDate>/g);
        dates.forEach(function(v, i){
            dates[i] = v.slice(9).slice(0, -10);
            dates[i] = new Date(dates[i]);
        });
        //log(dates);

        titles.forEach(function(v, i){
            model.insert({
                title:titles[i],
                content : contents[i],
                create_time : dates[i].getTime()/1000,
                author : 'wifeng',
                text_type : me._TEXT_TYPE.OLD
            });
            log(i)
        });
        db.close();
    }

};

// vim:ft=javascript
%>

