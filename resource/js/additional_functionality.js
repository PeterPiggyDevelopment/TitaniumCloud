$(document).bind('keyup', function (e){
    if(e.which==190 && e.ctrlKey) { //'Ctrl+.' bind
        document.body.innerHTML += '<canvas id="clickshist"></canvas>';
        var can = document.getElementById("clickshist");
        can.width = window.innerWidth-15;
        var body = document.body, html = document.documentElement;
        var height = Math.max( body.scrollHeight, body.offsetHeight, 
           html.clientHeight, html.scrollHeight, html.offsetHeight );
        can.height = height;
        var ctx = can.getContext("2d");
        ctx.fillStyle = 'black';
        var strs = httpGetPageClicks().split("@");
        var points=[];
        for (var i=1; i<strs.length; i++){
            points[i-1] = strs[i].split(',');
        }
        for (var i=0; i<points.length; i++){
            ctx.beginPath();
            ctx.arc(points[i][0],points[i][1],4,0,2*Math.PI);
            ctx.fill();
            ctx.stroke();
        }
    }
});

function httpGetPageClicks(){
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?getclicks="+window.location.pathname, false);
    xhttp.send();
    return xhttp.responseText;
}

function handleEvent(e){
    var evt = e ? e:window.event;
    var clickX=0, clickY=0;

    if ((evt.clientX || evt.clientY) &&
        document.body &&
        document.body.scrollLeft!=null) {
        clickX = evt.clientX + document.body.scrollLeft;
        clickY = evt.clientY + document.body.scrollTop;
    }
    if ((evt.clientX || evt.clientY) &&
        document.compatMode=='CSS1Compat' && 
        document.documentElement && 
        document.documentElement.scrollLeft!=null) {
        clickX = evt.clientX + document.documentElement.scrollLeft;
        clickY = evt.clientY + document.documentElement.scrollTop;
    }
    if (evt.pageX || evt.pageY) {
        clickX = evt.pageX;
        clickY = evt.pageY;
    }

    arr[Clicks-1]=[];
    arr[Clicks-1][0]=clickX;
    arr[Clicks-1][1]=clickY;
    var arrStr="@";
    for (var i=0; i<Clicks; i++){
        arrStr+=arr[i][0]+","+arr[i][1];
        if(i<Clicks-1) arrStr+="@";
    }
    //TODO: add onunload event and send data with it
    //httpSendClick(window.location.pathname, arrStr);
    Clicks++;
    return false;
}

var Clicks=1;
var arr=[];

function httpSendClick(page, arrStr){
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?pageclicked="+page+"&clicks="+arrStr, true);
    xhttp.send();
    return xhttp.readyState;
}
