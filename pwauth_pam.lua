package.cpath = package.cpath .. ";lua-?/?.so"

local pam = require "pam"

local function pam_conversation(messages, userdata)
	local username, password = userdata[1], userdata[2]

	local responses = {}

	for i, message in ipairs(messages) do
		local msg_style, msg = message[1], message[2]

		if msg_style == pam.PAM_PROMPT_ECHO_OFF then
			-- Assume PAM asks us for the password
			responses[i] = {password, 0}
		elseif msg_style == pam.PAM_PROMPT_ECHO_ON then
			-- Assume PAM asks us for the username
			responses[i] = {username, 0}
		elseif msg_style == pam.PAM_ERROR_MSG then
			responses[i] = {"", 0}
		elseif msg_style == pam.PAM_TEXT_INFO then
			responses[i] = {"", 0}
		else
			error("Unsupported conversation message style: %d", msg_style)
		end
	end

	return responses
end

local pwauth_pam = {}

pwauth_pam.__index = pwauth_pam

function pwauth_pam.conf(service)
	local cfg = {
		service = service
	}

	setmetatable(cfg, pwauth_pam)

	return cfg
end

function pwauth_pam.auth(cfg, username, password)
	local userdata = {username, password}

	local handle, err = pam.start(cfg.service, username, {pam_conversation, userdata})
	if not handle then
		return nil, err
	end

	local success, err = pam.authenticate(handle)
	if not success then
		return nil, err
	end

	local success, err = pam.endx(handle, pam.PAM_SUCCESS)
	if not success then
		return nil, err
	end

	return true
end

return pwauth_pam
