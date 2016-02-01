'use strict';

function typeDocument(string) { //определяет тип документа
            var pos=string.lastIndexOf('.'), //последнее вхождение точки
                length=string.length,
                type, //расширение файла
                src; //src иконки

            if (pos!=-1) {
              type=string.slice(pos+1, string.length);
            }
            else {
              type='';
            }

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
            else if (type=='') {
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
var isCopy=false, isCut=false;
function drawFunctions() { //создание всплывающего меню
  $('.parent').off('contextmenu');
    $('.parent').on('contextmenu', function(e) {

        $('.functions-menu').detach();
        var top=e.pageY-$('#listFile').offset().top,
            left=e.pageX-$(this).offset().left + 10,
            element=$(this),
            menu;



        e.preventDefault();
        $(this).append('<ul class="functions-menu"><li class="functions-menu-buttons" id="paste">Вставить</li><li class="functions-menu-buttons" id="copy">Копировать</li><li class="functions-menu-buttons">Вырезать</li><li class="functions-menu-buttons" id="delete">Удалить</li><li class="functions-menu-buttons" id="rename">Переименовать</li></ul>');
        if (isCopy==true || isCut==true) {
          $('#paste').css('display', 'block');
        }
        menu=$('.functions-menu');
        menu.css({
            'position': 'absolute',
            'top': top,
            'left': left
        });

        deleteFile(element, menu);
        renameFile(element, menu);
        isCopy=copyFile(element, menu);



    return false;
    });
};

function pasteFile(element, menu) {
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#paste')
  .on('click', 'li#paste', function(){
    element.clone(true).appendTo('section');
    var name=element.children().eq(1).text();
    name=name.slice(0, name.length-10);
    var k=identicalName(name);
    //element.children().eq(1).text(name);
    if (k!='-1' && k!='0') {
      if (name.lastIndexOf('.')!=-1) { //файл
        name=name.slice(0, name.lastIndexOf('.')) + ' (' + k+ ')'+name.slice(name.lastIndexOf('.'), name.length);
      }
    }
    var listFileText=$('.listFileText');
    listFileText.eq(listFileText.length-1).text(name);
    $('.functions-menu').detach();

    console.log(name);
  });
};


function copyFile(element, menu) {
  var copyFile;
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#copy')
  .on('click', 'li#copy', function(){
    isCopy=true;
    pasteFile(element, menu);
  });
  isCopy=isCopy;


  return isCopy;
}

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
                  text=zamena.text();//старое имя
              text=text.slice(0, text.length-10); //имя + расширение
              var first=text.lastIndexOf(' ('), //последнее вхождение " ("
                  pos=text.lastIndexOf('.'), //последнее вхождение точки
                  len=pos.length,
                  type; //расширение файла

                  if (text[first+2]%2!=NaN && text[first+3]==')' || text[first+2]%2!=NaN && text[first+3]%2!=NaN && text[first+4]==')') { //если файл имеет имя типа "name.type (number)"
                    type=string.slice(0, first); //убрали (number)
                    type=string.slice(pos+1, type.length); //обрезали всё, кроме расширения
                  }
                  else if (first==-1){
                    type='';
                  }
                  else {
                    type=string.substring(pos+1, len);
                  }
                  event.preventDefault();
              zamena.after('<input type="text" id="inputNewName">'); //вставили после текста поле ввода
              var inputNewName=$('#inputNewName');
              inputNewName.focus(); //делаем фокусировку вручную, потому что autofocus может быть применён только для одного поля на странице
              inputNewName.attr('value', text);
              inputNewName.select(); //выделение всего текста
              zamena.hide(); //скрыли текст
              inputNewName.blur(function() { //перестали вводить новое имя
                var newName=document.getElementById('inputNewName').value; //новое имя
                inputNewName.detach();
                zamena.show();
                zamena.replaceWith('<p class="listFileText" id="last"></p>');
                var last=$('#last');
                last.text(newName); //перезаписываем новое имя
                newName=changeText(newName, text); //проверяем новое имя на правильность, уникальность и пр.
                var newSrc=changeSrc(newName, type); //проверяем, изменилось ли расширение
                if (newSrc!=type && element.hasClass('folders')==false) { //если да, подбираем новую иконку
                  element.children().eq(0).attr('src', newSrc);
                };
                last.text(newName); //перезаписываем новое имя
                last.wrap('<div class="child"></div>');
                last.removeAttr('id');
              });
              inputNewName.keydown(function(event) {
                if (event.which==13) {
                  var newName=document.getElementById('inputNewName').value; //новое имя
                  inputNewName.detach();
                  zamena.show();
                  zamena.replaceWith('<p class="listFileText" id="last"></p>');
                  var last=$('#last');
                  last.text(newName); //перезаписываем новое имя
                  newName=changeText(newName, text); //проверяем новое имя на правильность, уникальность и пр.
                  var newSrc=changeSrc(newName, type); //проверяем, изменилось ли расширение
                  if (newSrc!=type) { //если да, подбираем новую иконку
                    element.children().eq(0).attr('src', newSrc);
                  };
                  last.text(newName);
                  last.wrap('<div class="child"></div>');
                  last.removeAttr('id');
                }
              })


    });
};

function identicalName(string) { //проверяет, нет ли таких же файлов
    var allText=$('.listFileText'),
        copy=[], //массив для копирования, так как мы не должны изменять имена других файлов
        main=0; //количество повторений

    for (var i=0; i<allText.length; i++) { //скопировали всё в другой массив
      copy[i]=allText.eq(i).text();
    }

    for (var i=0; i<copy.length; i++) {
        var first=copy[i].lastIndexOf(')'), //последнее вхождение ")";
            pos=copy[i].lastIndexOf('.'),
            type1=string.slice(pos+1, string.length),
            type2;
            if (first!=-1) {
              type2=string.slice(first+2, string.length);
            }
        if (type1==type2 && copy[i][first-1]%2!=NaN && copy[i][first-2]=='(') {
          copy[i]=copy[i].slice(0, pos-4) + copy[i].slice(copy[i].lastIndexOf('.'), copy[i].length);
        }
    }

    for (var i=0; i<copy.length; i++) {
      if (string==copy[i]) {
        main++;
      }
    }

    --main;

    return main.toString();
};

function correctName(name) { //пытался сделать через поиск подстроки, но не получилось
    var string=['/', ':', '?', '*', '"', '|', '{', '}', '[', ']'],
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
  var q=identicalName(newName);
  if (correctName(newName)==true && q!='0') { //имя корректное, но не уникальное
    if (newName.lastIndexOf('.')!=-1) {
      newName=newName.slice(0, newName.lastIndexOf('.'))+' ('+ q+')'+newName.slice(newName.lastIndexOf('.'), newName.length);
    }
    else {
      newName=newName + ' ('+q+')';
    }
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

  return newName;
};

function changeSrc(newName, oldSrc) { //поменял ли пользователь расширение файла
  var newSrc=newName.slice(newName.lastIndexOf('.')+1, newName.length);
  if (newSrc!=oldSrc) {
    newSrc=typeDocument(newName);
  }
  else {
    newSrc=oldSrc;
  };

  return newSrc;
};



//Функции для взаимодействия с сервером
function loadDir(dir) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "/?dir="+dir, true);
    xhttp.onreadystatechange = function() {
    if (xhttp.readyState == 4 && xhttp.status == 200)
        folder=sort(xhttp.responseText); //массив, с которого будем рисовать
        count=countFolders(folder); //количетво папок
        draw(folder); //отрисовали структуру
        renameFolders(); //переименовали папки
        createShare(); //создание кнопки "Поделиться"
    };
    xhttp.send();
}

function loadFile(dir, file) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "/?file="+file+"&dir="+dir, true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            downloadFile(xhttp.responseText);
        }
    };
    xhttp.send();
}

function openAndDownloadFile() {
  $('.parent').on('click', function() {
    var element=$(this);
    if(element.hasClass('folders')==true) { //если папка
      //код для открытия папки
    }
    else { //если файл
      //код для скачивания файла
    }
  })
}
