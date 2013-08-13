###

  Faviconr

  Andrey Popp (c) 2013

###

url         = require 'url'
express     = require 'express'
hyperquest  = require 'hyperquest'
sax         = require 'sax'

checkRel = (v) ->
  v == 'icon' or
    v == 'shortcut' or
    v == 'shortcut icon' or
    v == 'icon shortcut'

findFavicon = (cb) ->
  parser = sax.createStream(false)
  parser.on 'error', (err) ->
    cb(err)
  parser.on 'opentag', (node) ->
    if node.name == 'LINK' and checkRel node.attributes.REL
      cb(null, node.attributes.HREF)
  parser.on 'end', (node) ->
    cb(null)
  parser

requestFavicon = (uri, cb) ->
  hyperquest.get {uri}, (err, response) ->
    return cb(err) if err
    if /3\d\d/.exec response.statusCode
      requestFavicon(response.headers.location, cb)
    else if /2\d\d/.exec response.statusCode
      cb(null, uri)
    else
      cb(null)

module.exports = ->
  cache = {}
  app = express()
  app.get '/', (req, res) ->
    return res.send 400, 'provide URL as url param' unless req.query.url?
    return res.send cache[req.query.url] if cache[req.query.url]?

    {host, protocol} = url.parse(req.query.url)

    requestFavicon "#{protocol}//#{host}/favicon.ico", (err, icon) ->
      if icon
        cache[req.query.url] = icon
        res.send icon
      else
        hyperquest(uri: req.query.url, method: 'GET').pipe findFavicon (err, icon) ->
          if err or not icon?
            res.send 404
          else
            icon = url.resolve(req.query.url, icon)
            cache[req.query.url] = icon
            res.send icon

  app
