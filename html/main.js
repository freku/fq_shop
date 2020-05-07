window.onload = function(e) {
    $('#main').hide();
    $('#hide-w').hide();
    $('#hide-u').hide();
    var num = 0;
    var isShown = false;
    var lang;
    var staticBoughtList = {
        'pistol': {
            'supressor': [false, 7],
            'clip': [false, 8]
        }, 
        'submachine': {
            'supressor': [false, 9],
            'sight': [false, 10],
            'clip': [false, 11]
        },
        'shotgun': {
            'supressor': [false, 12],
            'grip': [false, 13]
        },
        'rifle': {
            'sight': [false, 3],
            'supressor': [false, 4],
            'clip': [false, 5],
            'grip': [false, 6]
        }
    };
    
    window.addEventListener("message", (event) => {
        var item = event.data;
        if (item !== undefined) {
            switch(item.type) {
                case 'ON_STATE':
                    if(item.display === true) {
                        $('#main').show();
                        isShown = true;
                        if (item.show !== undefined) {
                            for (var letter in item.show) {
                                $('#hide-' + item.show[letter]).show();
                            }
                        }
                    } else {
                        $('#main').hide();
                        $('#hide-w').hide();
                        $('#hide-u').hide();
                        isShown = false;
                        
                        $('#' + currentlyOpened).css('display', 'none');
                        $(lastPicked).toggleClass('nav-item-picked');
                        currentlyOpened = null;
                        lastPicked = null;
                    }
                    break;
                case 'ON_BOUGHT':
                    if (item.id !== undefined) {
                        if (item.id !== false) {
                            if (lang != 'pl') {
                                addMsg('You bought item!', false)
                            } else {
                                addMsg('Kupiłeś przedmiot!', false)
                            }
                            
                        } else {
                            if (lang != 'pl') {
                                addMsg('You can\'t buy it!', true)
                            } else {
                                addMsg('Nie możesz tego kupić!', true)
                            }
                        }
                    }
                    break;
                case 'ON_UPDATE':
                    if(item.data !== undefined) {
                        var ups = item.data;
                        var i = 0;
                        var j = 0;

                        for (var p in staticBoughtList) {
                            if (staticBoughtList.hasOwnProperty(p)) {
                                for (var o in staticBoughtList[p]) {
                                    staticBoughtList[p][o][0] = ups[i][j];
                                    j++;
                                }
                                i++;
                                j = 0;
                            }
                        }

                        updateBought();
                    }
                    break;
                case 'SET_LANG':
                    if (item.lang !== undefined) {
                        lang = item.lang
                        
                        if (lang == 'pl') {
                            $('#weapon-upgrades-box').text('Ulepszenia broni (na zawsze)');
                            $('#u-pistol-box').text('Ulepszenia pistoletów');
                            $('#u-submachine-box').text('Ulepszenia p.maszynowych');
                            $('#u-shotgun-box').text('Ulepszenia shotgunów');
                            $('#u-rifle-box').text('Ulepszenia karabinów');
                            $('#weaponons-box').text('Bronie');
                            $('#sniper-box').text('Snajperki');
                            $('#heavy-box').text('RPG itp.');
                            $('#throwable-box').text('Granaty, mołotowy');
                            $('#l-machine-box').text('Karabiny maszynowe');
                            $('#usable-box').text('Użytkowe');
                            $('#health-box').text('Leczenie');
                            $('#top-shop-title').text('Sklep Shotpex');
                        }
                    }
                    break;
                default:
                    break;
            }
        }
    });
    
    $(document).keydown((event) => {
        if(event.which == 27) { // 27 esc, 8 backspace
            if (isShown) {
                $.post('http://fq_shop/menuResult', JSON.stringify({
                    type: 'CLOSE_UI'
                }));
            }
        }
    });

    $('.item-buy-btn').click(function(){
        var isStatic = $(this).data('static');
        var id = parseInt($(this).data('id'));
        var cost = parseInt($(this).data('cost'));
        
        if (isStatic === undefined) {
            buyItem(id, cost, false);
        } else {
            var keys = isStatic.split(' ');

            if (!staticBoughtList[keys[0]][keys[1]][0]) {
                buyItem(id, cost, true);

            } else {
                if (lang != 'pl') {
                    addMsg('You already have it!', true);
                } else {
                    addMsg('Już to posiadasz!', true);
                }
            }
        }
    });

    var currentlyOpened = null;
    var lastPicked = null;

    $('ul ul li').click(function(){
        var attr = $(this).data('open');
        if (attr !== undefined) {
            if (currentlyOpened != null) {
                $('#' + currentlyOpened).css('display', 'none');
                $(lastPicked).toggleClass('nav-item-picked');
            }
            
            lastPicked = this;
            $(this).toggleClass('nav-item-picked');
            $('#' + attr).css('display', 'flex');    
            currentlyOpened = attr;
        }
    });

    $('.close-btn').click(function() {
        if (isShown) {
            $.post('http://fq_shop/menuResult', JSON.stringify({
                type: 'CLOSE_UI'
            }));
        }
    });

    window.buyItem = function(itemID, itemCost, isUps) {
        $.post('http://fq_shop/menuResult', JSON.stringify({
            type: 'ON_BUY',
            id: itemID,
            cost: itemCost,
            isUpgrade: isUps
        }));
    };

    window.updateBought = function() {
        for (var p in staticBoughtList) {
            var num = 0;
            var len = 0;
            if (staticBoughtList.hasOwnProperty(p)) {
                for (var o in staticBoughtList[p]) {
                    len++;
                    if (staticBoughtList[p][o][0]) {
                        var id = getFullId(staticBoughtList[p][o][1]);
                        
                        if (!$('#' + id).hasClass('item-static-bought')) {
                            $('#' + id).toggleClass('item-static-bought');
                            $('#' + id).children('button').toggleClass('btn-static-bought');
                        }
                        num++;
                    }
                }
            }

            var txt = $("li[data-open='"+ p +"-parts'] span").text();
            var words = txt.split(' ');
            $("li[data-open='"+ p +"-parts'] span").text(words[0]  + ' [' + num + '/' + len + ']')
        }
    };

    window.removeMsg = function(n) {
    	setTimeout(
        	() => $("p[test='" + n +"']").fadeOut('fast', function(){$(this).remove();})
        , 1250);
    }

    window.addMsg = function(msg, msgBad) {
        var el = $('<p></p>').text(msg).attr('test', num).toggleClass(msgBad ? 'msg-bad' : 'msg-good');

        $(el).hide().prependTo('.msg-box').fadeIn('fast');
        
        removeMsg(num)
        num++;
    }

    window.getFullId = function(id) {
        var str = 'item-';

        if (id < 10) {
            str += '0' + id;
        } else {
            str += id;
        }

        return str;
    } 

}