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

parseFavicon = (cb) ->
  parser = sax.createStream(false)
  seen = false
  parser.on 'error', (err) ->
    cb(err)
  parser.on 'opentag', (node) ->
    if node.name == 'LINK' and checkRel node.attributes.REL
      seen = true
      cb(null, node.attributes.HREF)
  parser.on 'end', (node) ->
    cb(null) unless seen
  parser

resolveURL = (uri, cb) ->
  hyperquest.get {uri}, (err, response) ->
    return cb(err) if err
    if /3\d\d/.exec response.statusCode
      resolveURL(response.headers.location, cb)
    else if /2\d\d/.exec response.statusCode
      cb(null, uri)
    else
      cb(null)

resolveFavicon = (uri, cb) ->
  {host, protocol} = url.parse(uri)

  resolveURL "#{protocol}//#{host}/favicon.ico", (err, icon) ->
    if icon
      cb(null, icon)
    else
      hyperquest(uri: uri, method: 'GET').pipe parseFavicon (err, icon) ->
        if err
          cb(err)
        else if not icon
          cb(null)
        else
          icon = url.resolve(uri, icon)
          cb(null, icon)

memoized = (func) ->
  cache = {}
  (args..., cb) ->
    return cb(null, cache[args]) if cache[args]?
    func args..., (err, result) ->
      cache[args] = result unless err
      cb(err, result)

module.exports = ->
  resolveFaviconMemoized = memoized resolveFavicon
  app = express()
  app.get '/', (req, res) ->
    return res.send 400, 'provide URL as url param' unless req.query.url?
    resolveFaviconMemoized req.query.url, (err, icon) ->
      if err or not icon
        res.send 404
      else
        res.send icon

  app

module.exports.makeApp = module.exports
module.exports.resolveFavicon = resolveFavicon
module.exports.parseFavicon = parseFavicon
