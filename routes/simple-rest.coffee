app = undefined
exports.init = (a) ->
  app = a
  this

exports.post = (url, f) ->
  app.post url, (req, res) ->
    fullBody = ""
    req.on "data", (chunk) ->
      fullBody += chunk.toString()

    req.on "end", ->
      result = f(JSON.parse(fullBody))
      res.write JSON.stringify(result)  if result

    res.end()


exports.get = (url, f) ->
  app.get url, (req, res) ->
    result = f(req.query)
    res.write JSON.stringify(result)  if result
    res.end()
