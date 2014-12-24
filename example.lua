require("uchat")

function on_connect(group) 
	print('connected to ' .. group.name);
end
function on_close(group)
	print('disconnected from ' .. group.name);
end
function on_message(group, user, message)
	print(group.name, user.name, message.body);
end

function on_connect_error(group, error)
	print(group, error);
end

function init()
	login['user'] = 'testaccount';
	login['password'] = 'testaccount';
	login['rooms'] = {'examplegroup'}
	event['on_disconnect'] = on_close;
	event['on_connect'] = on_connect;
	event['on_message'] = on_message;
	event['on_connect_error'] = on_connect_error;
end
mgr['on_init'] = init;
mgr.init()
mgr.main()
