function get(url, callback) {
    var request = new XMLHttpRequest();
    request.onreadystatechange=function() {
        if (request.readyState==4 && request.status==200) {
            if (callback && request.responseText) {
                callback(JSON.parse(request.responseText));
            }
        }
    }
    request.open("GET",url,true);
    request.send();
}

function post(url, data, callback) {
    var request = new XMLHttpRequest();
    request.onreadystatechange=function() {
        if (request.readyState==4 && request.status==200) {
            if (callback && request.responseText) {
                callback(JSON.parse(request.responseText));
            }
        }
    }
    request.open("POST",url,true);
    request.send(JSON.stringify(data));
}
