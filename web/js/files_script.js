var CurrentDirectory = '';

function getCurrentDirectory(){
    return '/'+getNameCookie()+'/'+CurrentDirectory;
}

function getNameCookie(){
    var co = document.cookie;
    co = co.slice(co.indexOf("=")+1, co.indexOf(";"));
    return co;
}

function back(){
    var pos=getCurrentDirectory().lastIndexOf('/');
    CurrentDirectory = getCurrentDirectory().slice(('/'+getNameCookie()+'/').length, pos);
    httpLoadDir(getCurrentDirectory());
}

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
                src='/resource/images/image.png';
            }
            else if (type=='pdf' || type=='txt' || type=='doc' || type=='xls' || type=='pptx' || type=='docx') {
                src='/resource/images/document.png';
            }
            else if (type=='fb2' || type=='epub' || type=='mobi') {
                src='/resource/images/book.png';
            }
            else if (type=='exe') {
                src='/resource/images/program.png';
            }
            else if (type=='mp3' || type=='amr') {
                src='/resource/images/music.png';
            }
            else if(type=='mp4' || type=='3gp' || type=='avi') {
                src='/resource/images/video.png';
            }
            else if (string[length-1]=='/' && string[length-2]=='/') {
            	src='/resource/images/folder.png';
            }
            else {
              src='/resource/images/other.png';
            }
return src;
};

<<<<<<< HEAD:resource/js/functions.js
function draw(li, name) { //отрисовка полосочек

     var trash=$('.parent');
     for (var i=0; i<trash.length; i++) trash.eq(i).detach(); //удалили всё, что было
     $('#name-user').detach();

   var length=li.length,
       listFile=$('#listFile');

     if (li[0].length!=' ') {
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

         $('.parent').eq(0).before('<div id="name-user"></div>');
         $('#name-user').prepend('<img class="child_img" src="image/user.png" id="person" align="right">');
         $('#person').after('<p id="user-text"></p>');
         $('#user-text').text(name);

         $('#name-user').before('<div id="main-menu"></div>');
         $('#main-menu').prepend('<div id="main-menu-left"></div>');
         $('#main-menu-left').after('<div id="main-menu-right"></div>')
         $('#main-menu-left').prepend('<img src="image/addfolder.png" class="hint--top hint--bounce child_img" data-hint="Bounce" id="qwerty">');
         $('#qwerty').after('<img src="image/addfile.png" class="hint--left hint--bounce child_img" data-hint="Bounce" id="qwerty2">')

         $('.parent').eq(length-1).css({
           'border-bottom-right-radius': '5px',
           'border-bottom-left-radius' : '5px'
         });

         $('.parent').eq(length-1).css('border-bottom', '1px solid #87CEEB');

     }
     else {
       $('.clear').detach();
       listFile.prepend('<p class="clear">Нет файлов, дружище</p>');
     }
=======
function draw(li) { //отрисовка полосочек
    var trash=$('.parent');
    for (var i=0; i<trash.length; i++) 
        trash.eq(i).detach(); //удалили всё, что было
    var length=li.length, listFile=$('#listFile');
    if (li[0].length!=' ') {
        for (var i=0; i<length; i++)
            listFile.prepend('<p class="listFileText"></p>');
        for (var i=0; i<length; i++) {
            $('.listFileText').eq(i).text(li[i]);
            $('.listFileText').eq(i).wrap('<div class="child"></div');
            $('.child').eq(i).wrap('<div class="parent"></div>');
            $('.child').eq(i).before('<img class="child_img">');
            var src=typeDocument(li[i]);
            $('.child_img').eq(i).attr('src', src);
        }
        $('.parent').eq(length-1).css('border-bottom', '1px solid #87CEEB');
        var cl = document.getElementById('clear');
        if (cl!=null) cl.remove();
    }
    else {
    listFile.prepend('<p id="clear">Нет файлов, дружище</p>');
    }
>>>>>>> b67d8a642fdc54dd97085a78c4ef7242c109fa26:web/js/files_script.js
};

Element.prototype.remove = function() {
    this.parentElement.removeChild(this);
}
NodeList.prototype.remove = HTMLCollection.prototype.remove = function() {
    for(var i = this.length - 1; i >= 0; i--) {
        if(this[i] && this[i].parentElement) {
            this[i].parentElement.removeChild(this[i]);
        }
    }
}

function createShare() {
    $('.parent').on('mouseover', function(event) {
      event.stopPropagation();
      event.preventDefault();
    $('.download').detach();
    var child=$(this).children().eq(1),
        text=child.children().eq(0);
    text.after('<p class="download"><span class="share_text">Поделиться</span></p>');
    });

    $('.parent').on('mouseout', function() {
        $('.download').detach();
    });

};

function drawFunctions() { //создание всплывающего меню
  $('.parent').off('contextmenu');
    $('.parent').on('contextmenu', function(e) {
        e.preventDefault();
        e.stopPropagation();
        $('.functions-menu').detach();

        var top=e.pageY-5,
            left=e.pageX+5,
            element=$(this),
            menu;

        e.preventDefault();
        $('body').append('<ul class="functions-menu"><li class="functions-menu-buttons" id="paste">Вставить</li><li class="functions-menu-buttons" id="copy">Копировать</li><li class="functions-menu-buttons" id="cut">Вырезать</li><li class="functions-menu-buttons" id="delete">Удалить</li><li class="functions-menu-buttons" id="rename">Переименовать</li></ul>');
        if (isCopy==true || isCut==true) {
          $('#paste').css('display', 'block');
        }
        menu=$('.functions-menu');
        menu.css({
            'position': 'absolute',
            'top': top,
            'left': left
        });

        //функции всплывающего меню
        deleteFile(element, menu);
        renameFile(element, menu);
        isCopy=copyFile(element, menu);
        isCut=cutFile(element, menu);

    return false; //чтобы не всплывало стандартное меню
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

var isCopy=false, isCut=false; //нажимал ли пользователь на "копировать" или "вырезать"
var OldName="";
var OldDir="";

function copyPasteFile(element, menu) {
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#paste')
  .on('click', 'li#paste', function(){
        var k=identicalName(OldName);
        var name = OldName;
    if (element.hasClass('folders')==false) { //файл
        if (k!='-1' && k!='0') {
            name=OldName.slice(0, OldName.lastIndexOf('.')) + ' (' + k+ ')'+OldName.slice(OldName.lastIndexOf('.'), OldName.length);
        }
        var listFileText=$('.listFileText'),
            newName=name;
        httpCopyFile(name, OldDir, newName, getCurrentDirectory());
    } else {
        if (k!='-1' && k!='0') {
          name=name + ' ('+k+')';
        }
        var listFileText=$('.listFileText'),
            newName=name;
        httpCopyDir(name, OldDir, newName, getCurrentDirectory());
    }
    $('.functions-menu').detach();

  });
};

function cutPasteFile(element, menu) {
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#paste')
  .on('click', 'li#paste', function(){
        var k=identicalName(OldName);
        var name = OldName;
    if (element.hasClass('folders')==false) { //файл
            if (k!='-1' && k!='0') {
                name=OldName.slice(0, OldName.lastIndexOf('.')) + ' (' + k+ ')'+OldName.slice(OldName.lastIndexOf('.'), OldName.length);
            }
        var listFileText=$('.listFileText'),
            newName=name;
        httpMoveFile(name, OldDir, newName, getCurrentDirectory());
    } else {
        if (k!='-1' && k!='0') {
          name=name + ' ('+k+')';
        }
        var listFileText=$('.listFileText'),
            newName=name;
        httpMoveDir(name, OldDir, newName, getCurrentDirectory());
    }
    $('.functions-menu').detach();

  });
};

function copyFile(element, menu) {
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#copy')
  .on('click', 'li#copy', function(){
    isCopy=true;
    OldName = element.children().eq(1).text();
    OldDir = getCurrentDirectory();
    copyPasteFile(element, menu);
  });
  isCopy=isCopy;
  return isCopy;
}

function cutFile(element, menu) {
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#cut')
  .on('click', 'li#cut', function(){
    isCut=true;
    OldName = element.children().eq(1).text();
    OldDir = getCurrentDirectory();
    cutPasteFile(element, menu);
    element.detach();
  });
  isCut=isCut;


  return isCut;
}

function deleteFile(element, menu) { //удаление
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#delete')
  .on('click', 'li#delete', function(){
      element.detach();
      var filename = element.children().eq(1).text();
      filename = filename.slice(0, filename.length-10);
      httpDeleteFile(getCurrentDirectory(), filename);
  });
};

function renameFile(element, menu) { //переименование
  $('#inputNewName').detach(); //удаляем старые поля
  var d=$(document);
    $(document).off('click', 'li#rename');
    $(document).on('click', 'li#rename', function(event) {
              var zamena=element.children().eq(1),
                  text=zamena.text();
              text=text.slice(0, text.length-10); //<--ДЖОН, ВОТ СТАРОЕ ИМЯ ФАЙЛА
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
              inputNewName.blur(function() { //перестали вводить новое имя (исчезла фокусировка на поле ввода)
                endRename(zamena, text, type, inputNewName, element);
              });
              inputNewName.keydown(function(event) { //перестали вводить новое имя (нажали на Enter)
                if (event.which==13) { //нажали именно Enter
                  endRename(zamena, text, type, inputNewName, element);
                }
              })
    });
};

function endRename(zamena, text, type, inputNewName, element) {
  var newName=document.getElementById('inputNewName').value; //новое имя
  inputNewName.detach();
  zamena.show();
  zamena.replaceWith('<p class="listFileText" id="last"></p>');
  var last=$('#last');
  last.text(newName); //перезаписываем новое имя
  newName=changeText(newName, text); //проверяем новое имя на правильность, уникальность и пр. <--ДЖОН, ВОТ НОВОЕ ИМЯ ФАЙЛА
  var newSrc=changeSrc(newName, type); //проверяем, изменилось ли расширение
  if (newSrc!=type && element.hasClass('folders')==false) { //если да, подбираем новую иконку
    element.children().eq(0).attr('src', newSrc);
  };
  last.text(newName);
  last.wrap('<div class="child"></div>');
  last.removeAttr('id');
  httpRenameFile(getCurrentDirectory(), text, newName);
}

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

(function addNewDirectory() { //создание новой папки
  $('#add_dir_button').on('click', function() {
    var folders=$('.folders'),
        count=folders.length; //количество папок
        $('section').prepend('<img class="child_img" src="image/folder.png" id="new">');
        var greenElephant=$('#new');
        greenElephant.wrap('<div class="parent folders" id="last"></div>');
        $('#new').after('<input type="text" id="inputNewName">');
        var inputNewName=$('#inputNewName');
        inputNewName.wrap('<div class="child"></div>');
        inputNewName.focus();
        greenElephant.removeAttr('id');
        inputNewName.blur(function() {
            endCreateNewDirectory(inputNewName)
        });

        inputNewName.keydown(function(event) {
          if (event.which==13) {
            endCreateNewDirectory(inputNewName)
          }
        });


});

})();

function endCreateNewDirectory(inputNewName) {
  var name=document.getElementById('inputNewName').value; //имя новой папки
  inputNewName.replaceWith('<p class="listFileText" id="newName"></p>');
  var newName=$('#newName');
  newName.text(name); //переименовали
  newName.removeAttr('id');
  newName.removeAttr('id');
  httpCreateDir(getCurrentDirectory(), name);
};

//Функции для взаимодействия с сервером
function httpLoadDir(dir) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?dir="+dir, true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            folder=sort(xhttp.responseText), //массив, с которого будем рисовать
            count=countFolders(folder); //количетво папок
            draw(folder, getNameCookie()); //отрисовали структуру
            renameFolders(); //переименовали папки
            openAndDownloadFile();
            createShare(); //создание кнопки "Поделиться"
            drawFunctions(dir); //отрисовка всплывающего меню при нажатии правой кнопкой мыши
            document.getElementById('globalDirectory').innerHTML = 'Current directory: /' + CurrentDirectory;
            document.getElementById('uploadfileinp').name = getCurrentDirectory();
        }
    };
    xhttp.send();
}

function httpLoadFile(dir, file) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?file="+file+"&dir="+dir, true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            downloadFile(xhttp.responseText);
        }
    };
    xhttp.send();
}

function httpDeleteFile(dir, file) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?del="+file+"&dir="+dir, true);
    xhttp.send();
    httpLoadDir(dir);
    return xhttp.readyState;
}

function httpRenameFile(dir, file, newname) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?rename="+file+"&newname="+newname+"&dir="+dir, true);
    xhttp.send();
    httpLoadDir(dir);
    return xhttp.readyState;
}

function httpMoveDir(file, dir, newname, newdir) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?dirmove="+file+"&olddir="+dir+"&newname="+newname+"&newdir="+newdir, true);
    xhttp.send();
    httpLoadDir(newdir);
    return xhttp.readyState;
}

function httpMoveFile(file, dir, newname, newdir) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?move="+file+"&olddir="+dir+"&newname="+newname+"&newdir="+newdir, true);
    xhttp.send();
    httpLoadDir(getCurrentDirectory());
    return xhttp.readyState;
}

function httpCopyDir(file, dir, newname, newdir) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?dircopy="+file+"&olddir="+dir+"&newname="+newname+"&newdir="+newdir, true);
    xhttp.send();
    httpLoadDir(newdir);
    return xhttp.readyState;
}

function httpCopyFile(file, dir, newname, newdir) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?copy="+file+"&olddir="+dir+"&newname="+newname+"&newdir="+newdir, true);
    xhttp.send();
    httpLoadDir(getCurrentDirectory());
    return xhttp.readyState;
}

function httpCreateFile(dir, file) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?create="+file+"&dir="+dir, true);
    xhttp.send();
    httpLoadDir(getCurrentDirectory());
    return xhttp.readyState;
}

function httpCreateDir(dir, file) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?dircreate="+file+"&dir="+dir, true);
    xhttp.send();
    httpLoadDir(getCurrentDirectory());
    return xhttp.readyState;
}

function openAndDownloadFile() {
    $('.parent').on('click', function() {
        var element=$(this);
        if (element.hasClass('functions-menu') == false){
            if(element.hasClass('folders')==true) { //если папка
                var dirname = element.children().eq(1).text();
                dirname = dirname.slice(0, dirname.length-10);
                if (getCurrentDirectory().lastIndexOf('/')==getCurrentDirectory().length-1){
                    CurrentDirectory += dirname;
                } else {
                    CurrentDirectory += "/"+dirname;
                }
                httpLoadDir(getCurrentDirectory());
            } else { //если файл
                var name = element.children().eq(1).text();
                name = name.slice(0, name.length-10);
                window.location.href=getCurrentDirectory()+'/'+name;
            }
        }
    })
};
