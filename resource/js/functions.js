function typeDocument(string) { //определяет тип документа
            var pos=string.lastIndexOf('.'), //последнее вхождение точки
                len=pos.length, //длина строки, начиная с точки
                length=string.length,
                type=string.substring(pos+1, len), //расширение файла
                src; //src иконки
                
            if (type=='jpg' || type=='png' || type=='jpeg' || type=='gif' || type=='bmp' || type=='tif') {
                src='image.png';
            }
            else if (type=='pdf' || type=='txt' || type=='doc' || type=='xls' || type=='pptx' || type=='docx') {
                src='document.png';
            }
            else if (type=='fb2' || type=='epub' || type=='mobi') {
                src='book.png';
            }
            else if (type=='exe') {
                src='program.png';
            }
            else if (type=='mp3' || type=='amr') {
                src='music.png';
            }
            else if(type=='mp4' || type=='3gp' || type=='avi') {
                src='video.png';
            }
            else if (string[length-1]=='/' && string[length-2]=='/') {
            	src='folder.png';
            }
            else {
                src='other.png';
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

console.log(arr);

return arr;
}

function loadDoc() {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "/.", true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            var folder = sort(xhttp.responseText);
            draw(folder);
        }
    };
    xhttp.send();
}
