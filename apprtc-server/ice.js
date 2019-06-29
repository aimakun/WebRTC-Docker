var express = require('express')
var crypto = require('crypto')
var cors = require('cors')
var app = express()

var hmac = function (key, content) {
  var method = crypto.createHmac('sha1', key)
  method.setEncoding('base64')
  method.write(content)
  method.end()
  return method.read()
}

function handleIceRequest(req, resp) {
  var query = req.query
  var key = '4080218913'
  var time_to_live = 600
  var timestamp = Math.floor(Date.now() / 1000) + time_to_live
  var turn_username = timestamp + ':ninefingers'
  var password = hmac(key, turn_username)

  return resp.send({
    iceServers: [
      {
        urls: [
          'stun:' + req.hostname + ':3478',
          'turn:' + req.hostname + ':3478'
        ],
        username: turn_username,
        credential: password
      }
    ]
  })
}

app.get('/iceconfig', cors(), handleIceRequest)
app.post('/iceconfig', cors(), handleIceRequest)

app.listen('3033', function () {
  console.log('server started')
})
