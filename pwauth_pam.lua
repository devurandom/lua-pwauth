package.cpath = package.cpath .. ";lua-?/?.so"

local pam = require "pam"

local function pam_conversation(messages, userdata)
	local username, password = userdata[1], userdata[2]
	if not (username and password) then
		error("Empty userdata?!")
	end

	local responses = {}

	for i, message in ipairs(messages) do
		local msg_style, msg = message[1], message[2]

		if msg_style == pam.PROMPT_ECHO_OFF then
			-- Assume PAM asks us for the password
			responses[i] = {password, 0}
		elseif msg_style == pam.PROMPT_ECHO_ON then
			-- Assume PAM asks us for the username
			responses[i] = {username, 0}
		elseif msg_style == pam.ERROR_MSG then
			responses[i] = {"", 0}
		elseif msg_style == pam.TEXT_INFO then
			responses[i] = {"", 0}
		else
			error("Unsupported conversation message style: " .. msg_style)
		end
	end

	return responses
end

local pwauth_pam = {}

pwauth_pam.__index = pwauth_pam

function pwauth_pam.new(service)
	local cfg = {
		service = service
	}

	setmetatable(cfg, pwauth_pam)

	return cfg
end

function pwauth_pam.authenticate(cfg, username, password)
	local userdata = {username, password}

	local handle, err = pam.start(cfg.service, username, {pam_conversation, userdata})
	if not handle then
		return nil, err
	end

	local success, err = handle:authenticate()
	if not success then
		return nil, err
	end

	local success, err = handle:endx(pam.SUCCESS)
	if not success then
		return nil, err
	end

	return true
end

return pwauth_pam
