#!/usr/bin/lua

local pwauth = require("pwauth").pam

io.write("Enter username: ")
local username = io.read()

io.write("Enter password: ")
local password = io.read()

local cfg = pwauth.new("system-auth")
if not cfg then
	error("Unable to create PAM config")
end

local success, err = cfg:authenticate(username, password)
if not success then
	error(err)
end
