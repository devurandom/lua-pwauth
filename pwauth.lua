package.cpath = package.cpath .. ";lua-?/?.so"

local pam = require "pam"

local pwauth = {}

pwauth.pam = require "pwauth_pam"

return pwauth
