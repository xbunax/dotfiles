--- aerospace module for sending commands to the AeroSpace window manager server
-- @module Aerospace
-- @copyright 2025
-- @license MIT
local cjson = require("cjson")
local socket = require("posix.sys.socket")
local unistd = require("posix.unistd")

local json = cjson.new()
local username = os.execute("id -un")

local DEFAULT_CONFIG = {
	SOCKET_PATH = string.format("/tmp/bobko.aerospace-%s.sock", username),
	MAX_BUFFER_SIZE = 2048,
	EXTENDED_BUFFER_SIZE = 4096,
}

--- Aerospace client class
-- @type Aerospace
local Aerospace = {}
Aerospace.__index = Aerospace

--- Error messages
local ERROR_MESSAGES = {
	SOCKET_CREATE = "Failed to create Unix domain socket",
	SOCKET_CONNECT = "Failed to connect to socket at %s",
	SOCKET_SEND = "Failed to send data through socket",
	SOCKET_RECEIVE = "Failed to receive data from socket",
	SOCKET_CLOSE = "Failed to close socket connection",
	SOCKET_NOT_CONNECTED = "Socket is not connected",
	JSON_DECODE = "Failed to decode JSON response",
	INVALID_WORKSPACE = "Invalid workspace identifier provided",
}

--- Creates a new Aerospace client and connects to the Unix domain socket.
-- @param socketPath (string|nil) Optional path to the Aerospace Unix socket
-- @return (table) New Aerospace client instance
-- @raise (error) If socket creation or connection fails
function Aerospace.new(socketPath)
	local self = setmetatable({}, Aerospace)
	self.socketPath = socketPath or DEFAULT_CONFIG.SOCKET_PATH

	local fd, err = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM, 0)
	if not fd then
		error(string.format("%s: %s", ERROR_MESSAGES.SOCKET_CREATE, tostring(err)))
	end

	self.fd = fd

	local addr = {
		family = socket.AF_UNIX,
		path = self.socketPath,
	}

	local ret, _ = socket.connect(self.fd, addr)
	if ret ~= 0 then
		unistd.close(fd)
		error(string.format(ERROR_MESSAGES.SOCKET_CONNECT, self.socketPath))
	end

	return self
end

--- Checks if the client is initialized and connected
-- @return (boolean) True if connected, false otherwise
function Aerospace:is_initialized()
	return self.fd ~= nil
end

--- Sends a query through the socket
-- @param query (table) Query to send
-- @return (number) Number of bytes sent
-- @raise (error) If sending fails
function Aerospace:send(query)
	if not self:is_initialized() then
		error(ERROR_MESSAGES.SOCKET_NOT_CONNECTED)
	end

	local encoded_query = json.encode(query) .. "\n"
	local bytes_sent, err = unistd.write(self.fd, encoded_query)

	if not bytes_sent then
		error(string.format("%s: %s", ERROR_MESSAGES.SOCKET_SEND, tostring(err)))
	end

	return bytes_sent
end

--- Receives data from the socket
-- @param maxBytes (number|nil) Optional maximum bytes to receive
-- @return (string) Received data
-- @raise (error) If receiving fails
function Aerospace:receive(maxBytes)
	if not self:is_initialized() then
		error(ERROR_MESSAGES.SOCKET_NOT_CONNECTED)
	end

	maxBytes = maxBytes or DEFAULT_CONFIG.MAX_BUFFER_SIZE
	local response, err = unistd.read(self.fd, maxBytes)

	if not response then
		error(string.format("%s: %s", ERROR_MESSAGES.SOCKET_RECEIVE, tostring(err)))
	end

	return response
end

--- Closes the socket connection
-- @raise (error) If closing fails
function Aerospace:close()
	if self:is_initialized() then
		local ok, err = unistd.close(self.fd)
		if ok ~= 0 then
			error(string.format("%s: %s", ERROR_MESSAGES.SOCKET_CLOSE, tostring(err)))
		end
		self.fd = nil
	end
end

--- Helper function to handle JSON responses
-- @param response (string) Raw response from socket
-- @return (table) Decoded JSON data
local function decode_response(response)
	local success, result = pcall(json.decode, response)
	if not success then
		error(string.format("%s: %s", ERROR_MESSAGES.JSON_DECODE, tostring(result)))
	end
	return result
end

--- Lists all available applications
-- @param callback (function|nil) Optional callback function to process results
-- @return (table) List of applications if no callback provided
function Aerospace:list_apps(callback)
	local query = {
		command = "",
		args = { "list-apps", "--json" },
		stdin = "",
	}

	self:send(query)
	local response = decode_response(self:receive(DEFAULT_CONFIG.MAX_BUFFER_SIZE))
	local apps = decode_response(response.stdout)

	if callback then
		return callback(apps)
	end
	return apps
end

--- Queries all workspaces
-- @param callback (function|nil) Optional callback function to process results
-- @return (table) Workspace information if no callback provided
function Aerospace:query_workspaces(callback)
	local query = {
		command = "",
		args = { "list-workspaces", "--all", "--format", "%{workspace}%{monitor-appkit-nsscreen-screens-id}", "--json" },
		stdin = "",
	}

	self:send(query)
	local response = decode_response(self:receive(DEFAULT_CONFIG.EXTENDED_BUFFER_SIZE))
	local workspaces = decode_response(response.stdout)

	if callback then
		return callback(workspaces)
	end
	return workspaces
end

--- Lists the current workspace
-- @param callback (function|nil) Optional callback function to process results
-- @return (string) Current workspace information if no callback provided
function Aerospace:list_current(callback)
	local query = {
		command = "",
		args = { "list-workspaces", "--focused" },
		stdin = "",
	}

	self:send(query)
	local response = decode_response(self:receive(DEFAULT_CONFIG.MAX_BUFFER_SIZE))

	if callback then
		return callback(response.stdout)
	end
	return response.stdout
end

--- Lists windows in a specific workspace
-- @param space (string) Workspace identifier
-- @param callback (function|nil) Optional callback function to process results
-- @return (table) Window information if no callback provided
-- @raise (error) If workspace identifier is invalid
function Aerospace:list_windows(space, callback)
	if not space or type(space) ~= "string" then
		error(ERROR_MESSAGES.INVALID_WORKSPACE)
	end

	local query = {
		command = "",
		args = { "list-windows", "--workspace", space, "--json" },
		stdin = "",
	}

	self:send(query)
	local response = decode_response(self:receive(DEFAULT_CONFIG.MAX_BUFFER_SIZE))

	if callback then
		return callback(response.stdout)
	end
	return response.stdout
end

Aerospace.__gc = Aerospace.close

return Aerospace
