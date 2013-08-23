get = (url, callback) ->
  request = new XMLHttpRequest()
  request.onreadystatechange = ->
    callback JSON.parse(request.responseText)  if callback and request.responseText  if request.readyState is 4 and request.status is 200

  request.open "GET", url, true
  request.send()
post = (url, data, callback) ->
  request = new XMLHttpRequest()
  request.onreadystatechange = ->
    callback JSON.parse(request.responseText)  if callback and request.responseText  if request.readyState is 4 and request.status is 200

  request.open "POST", url, true
  request.send JSON.stringify(data)
