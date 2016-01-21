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
