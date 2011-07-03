<%
//DEBUG_MODE = 1;
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
        var db = this._db();
        //log(db.model('posts').fieldsType());die()
        //db.model('posts').exportSql('posts.sql');die()
        var m = db.model('posts');
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
        var db;
        if(post){
            post = F.json.parse(post);
        }else{
            db = this._db();
            var model = db.model('posts');
            post = model.find('id='+id);
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
        db = this._db();
        var comments = db.model('comments').findAll('pid=' + post.id, '*', 'id desc');
        db.close();
        assign('comments', comments);
        assign('post', post);
        assign('page_title', post.title);
        display('template/blog/view.html');
    }
};
// vim:ft=javascript
%>

