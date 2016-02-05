function handleEvent(e){
    var evt = e ? e:window.event;
    var clickX=0, clickY=0;
    var arr=[];

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

    arr[0]=clickX;
    arr[1]=clickY;
    httpSendClick(window.location.pathname, arr);
    return false;
}

function httpSendClick(page, arr){
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", "/?pageclicked="+page+"&"+arr[0]+"="+arr[1], true);
    xhttp.send();
    return xhttp.readyState;
}

