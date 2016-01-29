

function typeDocument(string) { //определяет тип документа
            var pos=string.lastIndexOf('.'), //последнее вхождение точки
                len=pos.length, //длина строки, начиная с точки
                length=string.length,
                type=string.substring(pos+1, len), //расширение файла
                src; //src иконки

            if (type=='jpg' || type=='png' || type=='jpeg' || type=='gif' || type=='bmp' || type=='tif') {
                src='image/image.png';
            }
            else if (type=='pdf' || type=='txt' || type=='doc' || type=='xls' || type=='pptx' || type=='docx') {
                src='image/document.png';
            }
            else if (type=='fb2' || type=='epub' || type=='mobi') {
                src='image/book.png';
            }
            else if (type=='exe') {
                src='image/program.png';
            }
            else if (type=='mp3' || type=='amr') {
                src='image/music.png';
            }
            else if(type=='mp4' || type=='3gp' || type=='avi') {
                src='image/video.png';
            }
            else if (string[length-1]=='/' && string[length-2]=='/') {
            	src='image/folder.png';
            }
            else {
                src='image/other.png';
            }

return src;
};


function draw(li) { //отрисовка полосочек

     var trash=$('.parent');
     for (var i=0; i<trash.length; i++) trash.eq(i).detach(); //удалили всё, что было

   var length=li.length,
       listFile=$('#listFile');

     for (var i=0; i<length; i++) {
         listFile.prepend('<p class="listFileText"></p>');
     }

     for (var i=0; i<length; i++) {
         $('.listFileText').eq(i).text(li[i]);
         $('.listFileText').eq(i).wrap('<div class="child"></div');
         $('.child').eq(i).wrap('<div class="parent"></div>');
         $('.child').eq(i).before('<img class="child_img">');
         var src=typeDocument(li[i]);
         $('.child_img').eq(i).attr('src', src);
     }

     $('.parent').eq(length-1).css('border-bottom', '1px solid #87CEEB');
};

function createShare() { //костыли

    $('.child').on('mouseover', function() {
      $('.download').detach();
    var child=$(this).children().eq(1),
        text=child.children().eq(0);
    $(this).after('<p class="download"><span class="share_text">Поделиться</span></p>');

    });

    $('.child').on('mouseout', function() {
        $('.download').detach();
    });


    $('.parent').on('mouseover', function() {
    $('.download').detach();
    var child=$(this).children().eq(1),
        text=child.children().eq(0);
    text.after('<p class="download"><span class="share_text">Поделиться</span></p>');
    });

    $('.parent').on('mouseout', function() {
        $('.download').detach();
    });

};


function sort(string) { //сначала идут папки!
    var arr=string.split('\n'),
        length=arr.length,
        count=0;
    for (var i=0; i<length; i++) {
        var first=arr[i],
            lenFirst=first.length;
            for (var j=0; j<length-1; j++) {
                var second=arr[j],
                    lenSecond=second.length;

                if (arr[i][lenFirst-1]=='/' && arr[i][lenFirst-2]=='/' && arr[j][lenSecond-1]!='/' && arr[j][lenSecond-2]!='/')
                {
                    count++;
                    var trash=arr[i];
                    arr[i]=arr[j];
                    arr[j]=trash;
                }
            }
    }

return arr;
};

function countFolders(arr) {
    var count=0;
    for (var i=0; i<arr.length; i++) {
        if (arr[i].lastIndexOf('//')!=-1) {
            count++;
        }
    }

return count;
};

function renameFolders() { //удаление '//' из названия
        for (var i=0; i<count; i++) {
        $('.parent').eq(i).addClass('folders'); //идентифицировали папки
        var ch=$('.parent').eq(i).children().eq(1),
            children=ch.children().eq(0),
            text=children.text();
        text=text.substring(0, text.length-2);
        children.text(text);
    }
};

function drawFunctions() { //создание всплывающего меню
  $('.parent').off('contextmenu');
    $('.parent').on('contextmenu', function(e) {

        $('.functions-menu').detach();
        var top=e.pageY-$('#listFile').offset().top,
            left=e.pageX-$(this).offset().left + 10,
            element=$(this),
            menu;

        e.preventDefault();
        $(this).append('<ul class="functions-menu"><li class="functions-menu-buttons">Копировать</li><li class="functions-menu-buttons">Вырезать</li><li class="functions-menu-buttons" id="delete">Удалить</li><li class="functions-menu-buttons" id="rename">Переименовать</li></ul>');
        menu=$('.functions-menu');
        menu.css({
            'position': 'absolute',
            'top': top,
            'left': left
        });

        deleteFile(element, menu);
        renameFile(element, menu);


    return false;
    });
};

function deleteFile(element, menu) { //удаление
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#delete')
  .on('click', 'li#delete', function(){
      element.detach();
  });
};

function renameFile(element, menu) { //переименование
  $('#inputNewName').detach(); //удаляем старые поля
  var d=$(document);
    $(document).off('click', 'li#rename');
    $(document).on('click', 'li#rename', function(event) {
              var zamena=element.children().eq(1),
                  text=zamena.text(), //старое имя
                  first=text.lastIndexOf('.'),
                  type; //расширение файла

                  text=text.slice(0, text.length-10); //имя + расширение
                  type=text.slice(first+1, text.length);
                  event.preventDefault();
              zamena.after('<input type="text" id="inputNewName" placeholder="text">'); //вставили после текста поле ввода
              var inputNewName=$('#inputNewName');
              inputNewName.focus(); //делаем фокусировку вручную, потому что autofocus может быть применён только для одного поля на странице
              inputNewName.attr('value', text);
              zamena.hide(); //скрыли текст
              inputNewName.blur(function() { //перестали вводить новое имя
                var newName=document.getElementById('inputNewName').value; //новое имя
                inputNewName.detach();
                zamena.show();
                zamena.replaceWith('<p class="listFileText" id="last"></p>');
                var last=$('#last');
                newName=changeText(newName, text); //проверяем правильность, уникальность и пр.
                last.text(newName, text);
                last.wrap('<div class="child"></div>');
                last.removeAttr('id');
              });


    });
};

function identicalName(type) { //проверяет, нет ли таких же файлов
    var allText=$('.listFileText'),
        main=true; //нет одинаковых
    for (var i=0; i<allText.length; i++) {
        if (type==allText.eq(i).text()) {
            main=false; //есть одинаковые
            break;
        }
    }

    return main;
};

function correctName(name) { //пытался сделать через поиск подстроки, но не получилось
    var string=['/', ':', '?', '*', '"', '|', '{', '}', '[', ']'];
        main=true; //имя корректно
    for (var i=0; i<name.length; i++) {
        for (var j=0; j<string.length; j++) {
            if (name[i]==string[j]) {
                main=false; //имя не является корректным
                break;
            }
        }
    }

    return main;
};


function changeText(newName, oldName) {
  if (correctName(newName)==true && identicalName(newName)==false) { //имя корректное, но не уникальное
    newName=newName+' (1)';
  }
  else if(newName=='') { //новое имя пустое
    newName=oldName;
  }
  else if(correctName(newName)==false) { //имя не является корректным
    newName=oldName;
    $('body').prepend('<p id="alert-text">В имени файла не должны содержаться символы  &#"/:?*{}"|</p>');
    $('#alert-text').wrap('<div id="alert-wrap"></div>');
    $('#alert-wrap').fadeOut(10000);
  };
  console.log(oldName);
  return newName;
}
