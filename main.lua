local App = require('weblit-app')
local Json = require("json")

App.bind({
    host = "0.0.0.0",
    port = 8080
  })

  App.use(require('weblit-auto-headers'))
  App.use(require('weblit-etag-cache'))

  App.route({
    method = "GET",
    path = "/cubydatastore/get/:store/:key/:data",
  }, function (req, res, go)
    -- Handle route
  end)

  App.route({
    method = "PUT",
    path = "/cubydatastore/save/:store/:key/:data"
  }, function (req, res, go)
    local url = saveFile(req.params.username, req.body)
    res.code = 201
    res.headers.Location = url
  end)

  App.start()