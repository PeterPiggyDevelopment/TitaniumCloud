function loadDoc() {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "/.", true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            document.getElementById("super").innerHTML = xhttp.responseText;
        }
    };
    xhttp.send();
}
