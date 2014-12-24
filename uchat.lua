-- global objects --
mgr = {};
group = {};
message = {};
user = {};
login = {};
event = {};

-- LOCAL OBJECTS --

local map = {};

-- LOCAL VARS --
local host = 'ws://sv1.uchat.pw:443';
local connected = false;

-- local imports --
local ws = require('websocket');
local json = require('json');
-- local functions --

local function auth()
	local data = json.encode{event='bauth', name=login.user, pwd=login.password}
	map[group.name]:send(data)
end

local function sendcmd(...)
	local data = json.encode{...};
	print(data);
	cl:send(data);
end

local function events(e, evt)
	print(e, evt)
	if e.buc ~= nil then
		group['count'] = evt.uc;
	end
	if e.bmsg ~= nil then
		user['name'] = evt.un;
		message['body'] = evt.msg;
		event.on_message(group, user, message);
	end
	if e.block ~= nil then
		connected = false;
	end
	if e.authdeny ~= nil then
		group.disconnect();
		print('bad login');
	end
end
local function event_handle(data)
        local data = json.decode(data);
        local event = data['event'];
        events(event, data);
end

local function main()
	while connected do
		local data = map[group.name]:receive();
		event_handle(data);
	end
end		
local function uchat_connect(resource)
	local cl = ws.client.copas();
	local ok, _sockError = cl:connect(host, resource)
	if ok then
		group['name'] = resource;
		map[group.name] = cl;
		connected = true;
		event.on_connect(group);
		auth();
	else
		event.on_connect_error(group, _sockError);

	end
end
local function uchat_init()
	mgr.on_init()
	for i, resource in pairs(login.rooms) do
		resource = login.rooms[i];
		uchat_connect(resource);
	end
end

local function disconnect()
	cl:close();
end

local function killme()
	connected = false;
end

mgr['main'] = main;
group['send'] = send;
group['disconnect'] = disconnect;
mgr['killme'] = killme
mgr['init'] = uchat_init;
