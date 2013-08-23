hide = (id) ->
  document.getElementById(id).style.display = "none"
show = (id) ->
  document.getElementById(id).style.display = "block"
clear = (id) ->
  document.getElementById(id).innerHTML = ""