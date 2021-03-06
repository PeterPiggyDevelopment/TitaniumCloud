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

function typeDocument(string) {
            var pos=string.lastIndexOf('.'),
                length=string.length,
                type,
                src;

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

function draw(li, name) {

     var trash=$('.parent');
     for (var i=0; i<trash.length; i++) trash.eq(i).detach();
     $('#name-user').detach();
     $('#add_dir_button').detach();
     $('#back_button').detach();


   var length=li.length,
       listFile=$('#listFile');


     if (li[0].length!=' ') {
         $('.clear').detach();
         $('#qwerty2').detach();
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
     } else {
         $('.clear').detach();
         $('#qwerty2').detach();
         listFile.prepend('<p class="clear">Нет файлов, дружище</p>');
     }

         $('.parent').eq(0).before('<div id="name-user"></div>');
         $('#name-user').prepend('<img class="child_img" src="/resource/images/user.png" id="person" align="right">');
         $('#person').after('<p id="user-text"></p>');
         $('#user-text').text(name);

         $('#name-user').before('<div id="main-menu"></div>');
         $('#main-menu').prepend('<img src="/resource/images/addfolder.png" id="add_dir_button">');
         $('#add_dir_button').before('<img src="/resource/images/addfile.png" id="qwerty2">')
         $('#add_dir_button').wrap('<div class="hint--top hint--bounce child_img asdfg right" data-hint="Add new folder"></div>');
         $('#qwerty2').wrap('<div class="hint--top hint--bounce child_img asdfg right" data-hint="Upload files"></div>');
         $('#main-menu').prepend('<img src="/resource/images/back.png" id="back_button" onclick="back()">');
         $('#back_button').wrap('<div class="hint--top hint--bounce child_img" data-hint="Back""></div>');
         $('#qwerty2').wrap('<label></label>');
         $('#qwerty2').after('<iframe id="text_upload_container" name="hidden_frame" style="width:0px; height:0px; border:0px;">');
         $('#qwerty2').wrap('<form id="send_file_form" method="post", enctype="multipart/form-data" target="hidden_frame">')
         $('#qwerty2').after('<input id="uploadfileinp" name="uname" type="file"  onchange="changeInpName(this);" hidden>');

         buttons();

         $('.parent').eq(length-1).css({
           'border-bottom-right-radius': '5px',
           'border-bottom-left-radius' : '5px'
         });

         $('.parent').eq(length-1).css('border-bottom', '1px solid #87CEEB');
};

function changeInpName(elem){
    elem.name = getCurrentDirectory();
    elem.form.submit();
}

function handleResponse(){
    alert('Hooray! File downloaded!');
}

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

function drawFunctions() {
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

        deleteFile(element, menu);
        renameFile(element, menu);
        isCopy=copyFile(element, menu);
        isCut=cutFile(element, menu);

    return false;
    });
};

function sort(string) {
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

function renameFolders() {
        for (var i=0; i<count; i++) {
        $('.parent').eq(i).addClass('folders');
        var ch=$('.parent').eq(i).children().eq(1),
            children=ch.children().eq(0),
            text=children.text();
        text=text.substring(0, text.length-2);
        children.text(text);
    }
};

var isCopy=false, isCut=false;
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
    if (element.hasClass('folders')==false) {
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
    if (element.hasClass('folders')==false) {
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

function deleteFile(element, menu) {
  $(document).one('click', function(){
      menu.detach();
  })
  .off('click', 'li#delete')
  .on('click', 'li#delete', function(){
    element.detach();
    var filename = element.children().eq(1).text();
    if (element.hasClass('folders')==false) {
      httpDeleteFile(getCurrentDirectory(), filename);
    } else {
      httpDeleteDir(getCurrentDirectory(), filename);
    }
    httpLoadDir(dir);
  });
};

function renameFile(element, menu) {
  $('#inputNewName').detach();
  var d=$(document);
    $(document).off('click', 'li#rename');
    $(document).on('click', 'li#rename', function(event) {
              var zamena=element.children().eq(1),
                  text=zamena.text();
              text=text.slice(0, text.length-10);
              var first=text.lastIndexOf(' ('),
                  pos=text.lastIndexOf('.'),
                  len=pos.length,
                  type;

                  if (text[first+2]%2!=NaN && text[first+3]==')' || text[first+2]%2!=NaN && text[first+3]%2!=NaN && text[first+4]==')') {
                    type=string.slice(0, first);
                    type=string.slice(pos+1, type.length);
                  }
                  else if (first==-1){
                    type='';
                  }
                  else {
                    type=string.substring(pos+1, len);
                  }
                  event.preventDefault();
              zamena.after('<input type="text" id="inputNewName">');
              var inputNewName=$('#inputNewName');
              inputNewName.focus();
              inputNewName.attr('value', text);
              inputNewName.select();
              zamena.hide();
              inputNewName.blur(function() {
                endRename(zamena, text, type, inputNewName, element);
              });
              inputNewName.keydown(function(event) {
                if (event.which==13) {
                  endRename(zamena, text, type, inputNewName, element);
                }
              })
    });
};

function endRename(zamena, text, type, inputNewName, element) {
  var newName=document.getElementById('inputNewName').value;
  inputNewName.detach();
  zamena.show();
  zamena.replaceWith('<p class="listFileText" id="last"></p>');
  var last=$('#last');
  last.text(newName);
  newName=changeText(newName, text);
  var newSrc=changeSrc(newName, type);
  if (newSrc!=type && element.hasClass('folders')==false) {
    element.children().eq(0).attr('src', newSrc);
  };
  last.text(newName);
  last.wrap('<div class="child"></div>');
  last.removeAttr('id');
  httpRenameFile(getCurrentDirectory(), text, newName);
}

function identicalName(string) {
    var allText=$('.listFileText'),
        copy=[],
        main=0;

    for (var i=0; i<allText.length; i++) {
      copy[i]=allText.eq(i).text();
    }

    for (var i=0; i<copy.length; i++) {
        var first=copy[i].lastIndexOf(')'),
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

function correctName(name) {
    var string=['/', ':', '?', '*', '"', '|', '{', '}', '[', ']'],
        main=true;
    for (var i=0; i<name.length; i++) {
        for (var j=0; j<string.length; j++) {
            if (name[i]==string[j]) {
                main=false;
                break;
            }
        }
    }

    return main;
};

function changeText(newName, oldName) {
  var q=identicalName(newName);
  if (correctName(newName)==true && q!='0') {
    if (newName.lastIndexOf('.')!=-1) {
      newName=newName.slice(0, newName.lastIndexOf('.'))+' ('+ q+')'+newName.slice(newName.lastIndexOf('.'), newName.length);
    }
    else {
      newName=newName + ' ('+q+')';
    }
  }
  else if(newName=='') {
    newName=oldName;
  }
  else if(correctName(newName)==false) {
    newName=oldName;
    $('body').prepend('<p id="alert-text">В имени файла не должны содержаться символы  &#"/:?*{}"|</p>');
    $('#alert-text').wrap('<div id="alert-wrap"></div>');
    $('#alert-wrap').fadeOut(10000);
  };

  return newName;
};

function changeSrc(newName, oldSrc) {
  var newSrc=newName.slice(newName.lastIndexOf('.')+1, newName.length);
  if (newSrc!=oldSrc) {
    newSrc=typeDocument(newName);
  }
  else {
    newSrc=oldSrc;
  };

  return newSrc;
};

function addNewDirectory() {
  $('#add_dir_button').on('click', function() {
    var folders=$('.folders'),
        count=folders.length;
        $('#name-user').after('<img class="child_img" src="/resource/images/folder.png" id="new">');
        var greenElephant=$('#new');
        greenElephant.wrap('<div class="parent folders" id="last"></div>');
        $('#new').after('<input type="text" id="inputNewName">');
        var inputNewName=$('#inputNewName');
        inputNewName.wrap('<div class="child"></div>');
        inputNewName.focus();
        greenElephant.removeAttr('id');
        inputNewName.blur(function() {
          if (inputNewName.val!='')
            endCreateNewDirectory(inputNewName)
        });

        inputNewName.keydown(function(event) {
          if (event.which==13) {
           if (inputNewName.val!='')
             endCreateNewDirectory(inputNewName)
          }
        });


});

};

function endCreateNewDirectory(inputNewName) {
  var name=document.getElementById('inputNewName').value;
  inputNewName.replaceWith('<p class="listFileText" id="newName"></p>');
  var newName=$('#newName');
  newName.text(name);
  newName.removeAttr('id');
  newName.removeAttr('id');
  httpCreateDir(getCurrentDirectory(), name);
};

function httpLoadDir(dir) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?dir="+dir, true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            folder=sort(xhttp.responseText),
            count=countFolders(folder);
            draw(folder, getNameCookie());
            renameFolders();
            openAndDownloadFile();
            createShare();
            drawFunctions(dir);
            document.getElementById('globalDirectory').innerHTML = 'Current directory: /' + CurrentDirectory;
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

function httpDeleteDir(dir, file) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?dirdel="+file+"&dir="+dir, true);
    xhttp.send();
    return xhttp.readyState;
}

function httpDeleteFile(dir, file) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?del="+file+"&dir="+dir, true);
    xhttp.send();
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
            if(element.hasClass('folders')==true) {
                var dirname = element.children().eq(1).text();
                dirname = dirname.slice(0, dirname.length-10);
                if (getCurrentDirectory().lastIndexOf('/')==getCurrentDirectory().length-1){
                    CurrentDirectory += dirname;
                } else {
                    CurrentDirectory += "/"+dirname;
                }
                httpLoadDir(getCurrentDirectory());
            } else {
                var name = element.children().eq(1).text();
                name = name.slice(0, name.length-10);
                window.location.href=getCurrentDirectory()+'/'+name;
            }
        }
    })
};

function buttons() {
$('#back-button').on('click', function() {
  back();
});

$('#qwerty2').on('click', function() {
  var path=$('#test').val();

});

$('#add_dir_button').on('click', function() {
  addNewDirectory();
});
};

window.downloadFile = function (sUrl) {
    if (/(iP)/g.test(navigator.userAgent)) {
        alert('Your device does not support files downloading. Please try again in desktop browser.');
        return false;
    }
    if (window.downloadFile.isChrome || window.downloadFile.isSafari) {
        var link = document.createElement('a');
        link.href = sUrl;
        if (link.download !== undefined) {
            var fileName = sUrl.substring(sUrl.lastIndexOf('/') + 1, sUrl.length);
            link.download = fileName;
        }
        if (document.createEvent) {
            var e = document.createEvent('MouseEvents');
            e.initEvent('click', true, true);
            link.dispatchEvent(e);
            return true;
        }
    }
    window.open(sUrl, '_self');
    return true;
}
window.downloadFile.isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
window.downloadFile.isSafari = navigator.userAgent.toLowerCase().indexOf('safari') > -1;
