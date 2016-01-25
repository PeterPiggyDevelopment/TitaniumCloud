function showMenu(ul, position) {
    var pos = 0;
    var stopAnIn = false;
    var stopAnOut = false;
    var li=ul.children();
    ul.css("background-color", "rgba(4, 176, 237, 0)");
    window.onscroll = function() {
        var scrolled = window.pageYOffset;
        if (scrolled>position) {
            stopAnIn = false;
            stopAnOut = true;
            backgroundFadeIn(ul);
        }
        else {
            stopAnIn = true;
            stopAnOut = false;
            backgroundFadeOut(ul);
        }
     };

    function backgroundFadeIn(ul){
        var id = setInterval(frameIn, 10);
        function frameIn() {
            if ((pos >= 70) || (stopAnIn)) {
                clearInterval(id);
            } else {
                pos+=1;
                ul.css("background-color", "rgba(90, 94, 171, " + pos/100 + ")");
            }
        }
    }

    function backgroundFadeOut(ul){
        var id = setInterval(frameOut, 10);
        function frameOut() {
            if ((pos <= 0) || (stopAnOut)) {
                clearInterval(id);
            } else {
                pos-=1;
                ul.css("background-color", "rgba(90, 94, 171, " + pos/100 + ")");
            }
        }
    }
}
