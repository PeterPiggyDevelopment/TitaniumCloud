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

