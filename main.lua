local App = require('weblit-app')
local Json = require("json")
local QS = require("querystring")

--print(Json.encode({Levels = {}, Warnings = {}}))
local ENVFile = io.open("./.env", "r")

local Env = Json.decode(ENVFile:read("a*"))

ENVFile:close()

--print(Env.KEY)

App.bind({
    host = "0.0.0.0",
    port = 8080
  })

  --App.use(require('weblit-auto-headers'))
  App.use(require('weblit-etag-cache'))

  App.route({
    method = "GET",
    path = "/",
  }, function (req, res, go)
        res.body = '<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv="refresh" content="7; url=\'https://cuby.scriptitwithcod.repl.co/\'" />\n</head>\n</html>'
        res.headers["Content-Type"] = "text/html"
        res.code = 200
  end)

  App.route({
    method = "GET",
    path = "/" .. Env.KEY .. "/get/:store/:key",
  }, function (req, res, go)

        local File = io.open("./data.json", "r")
        local JsonData = File:read("*a")
        local LuaData = Json.decode(JsonData)
        File:close()

        local LuaReturn = {status = "ok", error = "", key = req.params.key}

        if LuaData[req.params.store] then
            LuaReturn.data = QS.urlencode(LuaData[req.params.store][req.params.key])
        else
            LuaReturn.status = "error"
            LuaReturn.error = "Store not found"
        end

        
        res.body = Json.encode(LuaReturn)
        res.headers["Content-Type"] = "application/json"
        res.code = 200
  end)

  App.route({
    method = "GET",
    path = "/" .. Env.KEY .. "/save/:store/:key/:data"
  }, function (req, res, go)
    
    local File = io.open("./data.json", "r+")
    local JsonData = File:read("*a")
    local LuaData = Json.decode(JsonData)
    File:close()

    local LuaReturn = {status = "ok", error = "", key = req.params.key}

    if LuaData[req.params.store] then
        if req.params.data ~= "" then
        LuaData[req.params.store][req.params.key] = req.params.data
        else
          LuaData[req.params.store][req.params.key] = nil
        end

        LuaReturn.data = LuaData[req.params.store][req.params.key]


        File = io.open("./data.json", "w+")
        File:write(Json.encode(LuaData))
    else
        LuaReturn.status = "error"
        LuaReturn.error = "Store not found"
    end

    
    res.body = Json.encode(LuaReturn)
    res.headers["Content-Type"] = "application/json"
    res.code = 200
    File:close()
  end)

  App.start()