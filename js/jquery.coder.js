/** 
 *           File:  jquery.coder.js
 *         Author:  Feng Weifeng(jpssff@gmail.com)
 *       Modifier:  Feng Weifeng(jpssff@gmail.com)
 *       Modified:  2011-06-14 16:14:13  
 *    Description:  将文本框变成一个编辑器。
 *      Copyright:  (c) 2011-2021 wifeng.cn
 */
(function($){
    $.fn.coder = function(opt){
        opt = $.extend({}, {
            expandtab : true,    // 是否将tab转化为空格
            tabstop : 4,         // tab键对应的空格数
            cursorHolder : '^!', // 光标占位符
            snippetKey : 9,      // tab键补全代码
            fileType : 'html',   // 默认为html
            snippets : {},       // 默认没有任何代码片段
            autoindent: true     // 是否自动缩进
        }, opt);

        var $this = this;

        //键值
        var TAB_KEY = 9, F1_KEY = 112, ENTER_KEY = 13, Y_KEY=89, Z_KEY=90, UP_KEY=38, DOWN_KEY=40;
        var CODER_KEY = 'WIFENG_CN_CODER', coder_data;

        //用于修改配置
        if(coder_data = $this.data(CODER_KEY)){
            $this.data(CODER_KEY, $.extend(coder_data, opt))
            return $this;
        }else{
            $this.data(CODER_KEY, opt);
        }

        var snippets = $.fn.coder._snippets;
        snippets[opt.fileType] = $.extend($.fn.coder._snippets[opt.fileType], opt.snippets);

        var dictionary = $.fn.coder._dictionary || {};

        //缩进字符
        var indentString = opt.expandtab ? new Array(opt.tabstop + 1).join(' ') : '\t';

        //状态
        var state = new State($this);

        return $this.keydown(function(e){
            var _this = this;
            var selection = $this.getSelection();

            //如果没有选中文本
            if(selection.start === selection.end){
                //代码片段替换
                if(e.keyCode === opt.snippetKey){
                    var word = getWordBeforeCursor($this, selection);
                    if(snippets[opt.fileType] && (word in snippets[opt.fileType])){
                        state.add();
                        replaceSnippet($this, word, snippets, opt.fileType, indentString, opt.cursorHolder);
                        state.add();
                        return false;
                    }
                }

                //将tab变成空格
                if(opt.expandtab){
                    if(e.keyCode === TAB_KEY){
                        state.add();
                        var se = $this.getSelection();
                        $this.replaceSelection(indentString);
                        $this.setSelection(se.start + indentString.length);
                        return false;
                    }
                }
            }
            //光标选中了文本
            else{
                if(e.shiftKey){
                    //如果是同时按下shift和tab键，进行反缩进
                    if(e.keyCode === TAB_KEY){
                        reindentLines($this, indentString);
                        state.add();
                        return false;
                    }
                }else if(e.keyCode === TAB_KEY){
                    indentLines($this, indentString);
                    state.add();
                    return false;
                }
            }

            //阻止浏览器的对tab键的默认行为
            if(e.keyCode === TAB_KEY){
                //直接增加tab
                appendWords($this, $this.getSelection().start, '\t');
                state.add();
                return false;
            }

            //单词提示
            if(e.ctrlKey && e.keyCode === DOWN_KEY){
                var word = getWordBeforeCursor($this, selection);
                if(word){
                    completeWord($this, selection, word, dictionary, 1);
                }
                return false;
            }

            //单词提示
            if(e.ctrlKey && e.keyCode === UP_KEY){
                var word = getWordBeforeCursor($this, selection);
                if(word){
                    completeWord($this, selection, word, dictionary, -1);
                }
                return false;
            }

            //自动缩进
            if(opt.autoindent && !e.ctrlKey && e.keyCode === ENTER_KEY){
                state.add();
                var indentCount = getIndetCount($this.val(), selection.start, indentString);
                if(indentCount > 0){
                    var str = '\n' + new Array(indentCount + 1).join(indentString);
                    appendWords($this, selection.start, str);
                    state.add();
                    return false;
                }
            }

            //运行
            if(e.ctrlKey && e.keyCode === ENTER_KEY){
                try{
                    runCode($this);
                }catch(e){}
                _this.focus();
                return false;
            }

            //帮助
            if(e.keyCode === F1_KEY){
                e.preventDefault();
                alert(
                   '** js coder ** \n\n' + 
                   'F1 -- show this help\n' +
                   'Tab -- indent selected lines\n' +
                   'Shift-Tab -- indent back\n' +
                   'Ctrl-Z  -- undo\n' +
                   'Ctrl-Y  -- redo\n' +
                   'Ctrl-↓  -- complete word next\n' + 
                   'Ctrl-↑  -- complete word prevous\n' + 
                   'Ctrl-Enter -- run the code in a new window\n\n' + 
                   '@ 2011 by fengweifeng'
                );
                return false;
            }

            //撤销一步
            if(e.ctrlKey && e.keyCode === Z_KEY){
                state.undo();
                e.preventDefault();
                return false;
            }

            //重做一步
            if(e.ctrlKey && e.keyCode === Y_KEY){
                state.redo();
                e.preventDefault();
                return false;
            }

            //保存状态
            state.add();

            //让其他键正常使用
            return true;
        });
    };

    $.snippets = function(type, snippets){
        $.fn.coder._snippets[type] = snippets;
    };

    $.fn.coder._snippets = {};

    $.dictionary = function(data){
        $.fn.coder._dictionary = data;
    };

    //自动完成单词
    function completeWord($this, selection, word, dict, dir){
        var coms = [], sugs, cache = completeWord.cache;
        var k = word.slice(0, 1);
        var ext = selection.text;
        //如果光标位置和单词都没变，则查缓存
        if(cache.start === selection.start && cache.word === word){
            coms = cache.data;
        }else{
            var map = getExistWrodsMap($this, selection, word);
            if(k in dict){
                sugs = getSuggestWords(word, dict[k]);
            }
            if(sugs.length){
                coms = sugs;
            }
            var i = 0;
            while(coms[i] !== undefined){
                if(coms[i] in map){
                    coms.splice(i, 1);
                    continue;
                }
                i++;
            }
            var temp = [];
            for(var i in map){
                temp.push(i);
            }
            temp = temp.sort();
            coms = temp.concat(sugs);

            //将此次查询放入缓存，提高补全效率
            cache.word = word;
            cache.start = selection.start;
            cache.data = coms;
        }
        if(coms.length){
            var sug = fetchSuggest(word, coms, ext, dir);
            var se = selection;
            appendWords($this, se.start, sug);
            $this.setSelection(se.start, se.start + sug.length);
        }
    }
    completeWord.cache = {word:'', start:0, data: []};

    //获取已经存在的单词
    function getExistWrodsMap($this, selection, word){
        var map = {};
        var value = $this.val();
        value = value.substring(0, selection.start - word.length) + ' ' + value.substr(selection.end);
        var words = value.split(/\W/), temp;
        for(var i=0, l=words.length; i<l; i++){
            temp = words[i];
            if(temp === ''){
                continue;
            }
            if(temp in map){
                continue;
            }else{
                if(temp.length > 1 && temp !== word && temp.indexOf(word) === 0){
                    map[temp] = null;
                }
            }
        }
        return map;
    }

    //取出一个词
    function fetchSuggest(w, sugs, ext, dir){
        var t = w + ext, index = -1, l=sugs.length;
        for(var i=0; i<l; i++){
            if(sugs[i] === t){
                index = i;
                break;
            }
        }
        return sugs[(index + (1*dir) + l)%l].slice(w.length);
    }

    //返回匹配的词组
    function getSuggestWords(w, dict){
        var res = [];
        for(var i=0, l=dict.length; i<l; i++){
            var index = dict[i].indexOf(w);
            if(index === 0){
                res.push(dict[i]);
            }
        }
        return res;
    }

    //获取光标前的单词
    function getWordBeforeCursor($this, selection){
        if(!selection){
            selection = $this.getSelection();
        }
        var value = $this.val().substring(0, selection.start)
        var word = value.match(/\s*(\w+)$/);
        if(word && word.length){
            word = word.pop();
        }
        return word;
    }

    //替换字符串的缩进字符
    function replaceIndent(str, indentString){
        var pices = str.split(/\n/);
        for(var i=0; i<pices.length; i++){
            pices[i] = pices[i].replace(/^\t+/, function(ts){
                return new Array(ts.length + 1).join(indentString);
            });
        }
        return pices.join('\n');
    }

    //计算缩进次数
    function getIndetCount(value, start, indentString){
        if(indentString.length === 0)
            return 0;
        var subindex = value.substring(0, start).lastIndexOf('\n');
        var spaces = value.substring(subindex + 1, start).match(/^( |\t)+/);
        if(!spaces){
            return 0;
        }
        var space = spaces[0];
        var temp = space, s, count = 0;
        while((s = temp.replace(indentString, '')) !== temp){
            count ++;
            temp = s;
        }
        return count;
    }

    //在光标下插入文本
    function appendWords($t, start, words){
        $t.replaceSelection(words);
        $t.setSelection(start + words.length);
    }

    //替换片段
    function replaceSnippet($t, word, snippets, ft, indentString, cursorHolder){
        var $this = $t;
        var _this = $t[0];
        //如果有映射，则替换
        var snippet = snippets[ft][word];
        var se = $this.getSelection();
        var start = se.start - word.length;
        var end = se.start;

        //先将缩写词删除
        $this.setSelection(start, end).replaceSelection('');
        $this.setSelection(start);

        //缩进替换
        var insertValue = replaceIndent(snippet, indentString);

        //获取对照的缩进空白字符
        var indentCount = getIndetCount($this.val(), start, indentString);
        if(indentCount > 0){
            var space = new Array(indentCount + 1).join(indentString);
            insertValue = insertValue.replace(/\n/g, '\n' + space);
        }

        //插入替换文本
        $this.replaceSelection(insertValue);

        //替换光标占位符
        var cursor = start;
        var holderIndex = insertValue.indexOf(cursorHolder);
        if(holderIndex !== -1){
            cursor += holderIndex;
            $this.setSelection(cursor, cursor + cursorHolder.length).replaceSelection('');
        }else{
            cursor += snippet.length;
        }

        //摆正光标位置
        $this.setSelection(cursor);
    }

    //获取选中完整行的信息
    function getLinesSelection($t){
        var $this = $t;
        var se = $this.getSelection();
        var value = $this.val();
        var lastBr = value.substring(0, se.start).lastIndexOf('\n');
        if(lastBr > -1){
            se.lineStart = lastBr + 1;
        }else{
            se.lineStart = 0;
        }
        var nextBr = value.indexOf('\n', se.end);
        if(nextBr > -1){
            se.lineEnd = nextBr;
        }else{
            se.lineEnd = value.length;
        }
        se.lineText = value.substring(se.lineStart, se.lineEnd);
        return se;
    }

    //缩进多行
    function indentLines($t, indentString){
        var $this = $t;
        var se = getLinesSelection($this);
        var lines = se.lineText.split('\n');
        var temp = 0, step = indentString.length;
        for(var i=0, l=lines.length; i<l; i++){
            lines[i] = indentString + lines[i];
            temp += step;
        }
        $this.setSelection(se.lineStart, se.lineEnd).replaceSelection(lines.join('\n'));
        $this.setSelection(se.lineStart, se.lineEnd + temp);
    }

    //反缩进多行
    function reindentLines($t, indentString){
        var $this = $t;
        var se = getLinesSelection($this);
        var lines = se.lineText.split('\n');
        var temp = 0, step = indentString.length;
        for(var i=0, l=lines.length; i<l; i++){
            if(lines[i].indexOf(indentString) === 0){
                lines[i] = lines[i].slice(step);
                temp += step;
            }
        }
        $this.setSelection(se.lineStart, se.lineEnd).replaceSelection(lines.join('\n'));
        $this.setSelection(se.lineStart, se.lineEnd - temp);
    }

    //运行代码
    function runCode($t){
        var code = $t.val();
        var win = window.open('', "_blank", '');
        win.document.open('text/html', 'replace');
        win.opener = null;
        win.document.write(code);
        win.document.close();
    }

    //状态管理器
    function State($t){
        this.MAX = 100;
        this.$t = $t;
        this.t = $t[0];
        this.current = 0;
        this.latest = 0;
        this.cache = new Array(this.MAX + 1);
        this.cache[0] = {value:$t.val(), selection:{start:0, end:0, text:''}, scroll:0};
        this.cache[-1] = {value:$t.val(), selection:{start:0, end:0, text:''}, scroll:$t[0].scrollTop};
        var o = this;

        //添加一个状态
        this.add = function(){
            if(this.$t.val() === this.cache[this.latest % this.MAX].value)
                return;
            if(this.latest !== this.current){
                this.latest = this.current + 1;
            }else{
                this.latest ++;
            }
            this.cache[this.latest % this.MAX] = {
                value : o.$t.val(),
                selection : $t.getSelection(),
                scroll : o.t.scrollTop
            };
            this.current = this.latest;
        };

        //撤销
        this.undo = function(){
            if(this.current === 0 || this.latest - this.current + 1 === this.MAX){
                this.update(-1);
                return;
            }
            this.current --;
            this.update(this.current);
        };

        //重做
        this.redo = function(){
            if(this.current === this.latest){
                return;
            }
            if(this.cache[(this.current+1)%this.MAX] !== undefined){
                this.current ++;
                this.update(this.current);
            }
        };

        //更新状态
        this.update = function(index){
            var v = this.cache[index % this.MAX];
            this.$t.val(v.value);
            this.t.scrollTop = v.scroll;
            this.$t.setSelection(v.selection.start, v.selection.end);
            this.t.focus();
        };
    }
})(jQuery);

