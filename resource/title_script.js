var ul=document.getElementsByTagName('ul')[0],
    li=document.getElementsByTagName('li');
for (var i=0; i<li.length; i++) 
    li[i].style.display='none';

window.onscroll = function() {
var scrolled = window.pageYOffset;
    if (scrolled>300) {
        for (var i=0; i<li.length; i++) li[i].style.display='inline';
            ul.style.backgroundColor='black';
        }
    else {
        for (var i=0; i<li.length; i++) li[i].style.display='none';
            ul.style.backgroundColor='transparent';
    }
};
function loadDoc() {
    var xhttp = new XMLHttpRequest();
    var params = "lorem=ipsum&name=binny";
    xhttp.open("POST", "ajax_info.txt", true);
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    http.setRequestHeader("Content-length", params.length);
    http.setRequestHeader("Connection", "close");
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            document.getElementById("super").innerHTML = xhttp.responseText;
        }
    };
    xhttp.send(params);
}
