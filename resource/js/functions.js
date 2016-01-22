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
         src=typeDocument(li[i]);
         $('.child_img').eq(i).attr('src', src);
     }

     $('.parent').eq(length-1).css('border-bottom', '1px solid #87CEEB');
};      

function createShare() {$('.parent').on('mouseover', function() { //создание кнопки поделиться
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
}

function loadDir() {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "/.?dir=/resource", true);
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

function loadFile(file) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "/.?file="+file+"&dir=resource", true);
    /*xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            draw(sort(xhttp.responseText));
        }
    };*/
    xhttp.send();
}

function countFolders(arr) {
    var count=0;
    for (var i=0; i<arr.length; i++) {
        if (arr[i].lastIndexOf('//')!=-1) {
            count++;
        }
    }

return count;
}

function renameFolders() {
        for (var i=0; i<count; i++) {
        $('.parent').eq(i).addClass('folders'); //идентифицировали папки
        var ch=$('.parent').eq(i).children().eq(1),
            children=ch.children().eq(0),
            text=children.text();

        text=text.substring(0, text.length-2);

        children.text(text);
    }
}
