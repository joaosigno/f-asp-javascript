<%
//管理员部分
F.controller.admin = {
    _init: function(){
        F.controller.blog._init();
        if(ACTION !== 'login'){
            if(!F.User.isLogin()){
                F.go('/?r=admin&a=login');
            }
        }
        if(F.isAjax()){
            F.header('Content-Type', 'application/json');
        }
    },

    _db: function(){
        return F.controller.blog._db();
    },

    _TEXT_TYPE : F.controller.blog._TEXT_TYPE,

    index: function(){
        F.go('/?r=blog');
    },

    login: function(){
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

    //编辑文章
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

    //压缩数据库
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

    //导出xml
    xml: function(){
        var db = this._db();
        var model = db.model('posts');
        var name = new Date().format('YYYY-MM-DD_hh-mm-ss') + '.xml'
        model.exportXml(name);
        db.close();
        echo('导出成功， 文件名为：<a href="' + name + '">' + name + '</a>');
    },

    //导出sql文件
    sql: function(){
        var db = this._db();
        db.tableNames().forEach(function(v){
            var name = v + new Date().format('_YYYY-MM-DD_hh-mm-ss') + '.sql';
            db.model(v).exportSql(name);
            echo('<p>导出表"'+v+'"成功， 文件名为：<a href="' + name + '">' + name + '</a>');
        });
    },

    //清空缓存
    removecache: function(){
        F.cache.remove();
        F.go('/?r=admin');
    },

    file: function(){
        var path = F.get('path') || '.';
        var isFile = F.get('type') === 'file';
        var say = function(obj, statusCode){
            var a = {status: statusCode || 0};
            obj = obj || {};
            for(var i in obj){
                a[i] = obj[i];
            }
            die(F.json.stringify(a));
        };
        if(F.isAjax()){
            if(F.isGet()){
                if(isFile){
                    var f = new F.File(path);
                    if(f.exist()){
                        say({content:f.getText()});
                    }else{
                        say({'msg':'文件不存在'}, 1);
                    }
                }else{
                    var folder = new F.Folder(path);
                    if(folder.exist()){
                        var data = {
                            'folders' : folder.folders(),
                            'files': folder.files()
                        };
                        say(data);
                    }else{
                        say({'msg':'文件夹不存在'}, 1);
                    }
                }
            }else if(F.isPost()){
                var action = F.get('action') || 'save';
                if(action === 'save'){
                    var f = new F.File(path);
                    if(f.exist()){
                        f.setText(F.post('content'));
                        say();
                    }else{
                        say({'msg':'文件不存在'}, 1);
                    }
                }else if(action === 'remove'){
                    var f;
                    if(isFile)
                        f= new F.File(path);
                    else
                        f = new F.Folder(path);
                    if(f.exist()){
                        try{
                            f.remove();
                            say();
                        }catch(e){
                            say({msg:e.message}, 1);
                        }
                    }else{
                        say({msg:'文件或文件夹不存在'}, 1);
                    }
                }else if(action === 'create'){
                    var f, name = F.post('name');
                    if(name.trim() === ''){
                        say({msg:'请输入名称'}, 1);
                    }
                    if(isFile)
                        f = new F.File(path + '/' + name);
                    else
                        f = new F.Folder(path + '/' + name);
                    if(f.exist()){
                        say({msg:'文件或文件夹已存在'}, 1);
                    }else{
                        try{
                            f.create();
                            say();
                        }catch(e){
                            say({msg:e.message}, 1);
                        }
                    }
                }
            }
        }else{
            var f = new F.Folder('.');
            assign('path', f.path);
            display('template/blog/file.html');
        }
    },

    comment: function(){
        var id = parseInt(F.get('id')) || 0;
        var action = F.get('action');
        var db = this._db();
        var m = db.model('comments');
        if(F.isGet()){
            assign('comment_html', m.html(null, null, null, null, {
                cols:[
                    {
                        th : '删除',
                        td : function(row){
                            return '<a href="#" class="c-del" data-id="'+row.id+'">删除</a>';
                        }
                    }
                ]
            }));
            display('template/blog/comment.html');
        }else{
            var as = {
                del:function(){
                    m.del('id=' + id);
                    echo('{"status":0}');
                }
            };
            if(action in as)
                as[action]();
        }
        db.close();
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

