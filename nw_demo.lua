--[[
- function nw:app()
- function app:run(); ignored while running
function app:quit(); works from closed(), not from closing()
- function app:screen_rect()
- function app:client_rect()
- function app:window(t); x,y,w,h,title,visible,state=minimized,state=maximized
- function app:windows()
- function app:closed(window)
- function window:free()
- function window:dead()
- function window:closing()
- function window:closed()

- function window:activate()
- function window:active()
- function window:activated() end
- function window:deactivated() end
- function window:show(state)
- function window:hide()
- function window:visible()
- function window:state()
- function window:frame_changing(how, x, y, w, h) end --move|left|right|top|bottom|topleft|topright|bottomleft|bottomright
- function window:resized() end
- function window:moved() end
function window:state_changed() end
function window:frame_rect(x, y, w, h) return self.impl:frame_rect(x, y, w, h) end --x, y, w, h
function window:client_rect() return self.impl:client_rect() end --x, y, w, h

- function window:title(newtitle)

- function window:key_down(key) end
- function window:key_up(key) end
- function window:key_press(key) end
- function window:key_char(char) end

- function window:mouse_up(button) end
- function window:mouse_down(button) end
- function window:click(button) end
- function window:mouse_wheel(delta) end

- function window:render() end
- function window:invalidate()
]]

local nw = require'nw'

local app = nw:app()

print('screen_rect', app:screen_rect())
print('client_rect', app:client_rect())
print('double_click_time', app.impl:double_click_time())

local win1 = app:window{x = 100, y = 100, w = 800, h = 400, title = 'win1', visible = false}
local win2 = app:window{x = 200, y = 400, w = 600, h = 200, title = 'win2', visible = false,
								frame = false, allow_resize = false, allow_minimize = false, allow_maximize = false,
								allow_close = true}

for win in app:windows() do
	win:title('[' .. win:title() .. ']')
	print('title', win:title())
end

function app:closed(win) print('closed', win:title()) end

function win1:closing() print'closing win1' end
function win2:closing() print'closing win2' end
function win1:closed() print'closed win1' end
function win2:closed() print'closed win2' end
function win1:activated() print'activated win1' end
function win2:activated() print'activated win2' end
function win1:frame_changing(how, x, y, w, h)
	if how == 'move' then
		x = math.min(math.max(x, 50), 250)
		y = math.min(math.max(y, 50), 250)
	end
	return x, y, w, h
end
function win1:moved()
	print'moved win1'
	win1:invalidate()
end

function win1:render(cr)
	cr:rectangle(10, 10, 100, 100)
	cr:set_source_rgba(1, 0, 0, 1)
	cr:fill()
	cr:rectangle(150, 150, 100, 100)
	cr:set_source_rgba(1, 0, 0, 0.5)
	cr:fill()
end

function win2:moved() print'moved win2' end
function win1:resized() print'resized win1' end
function win2:resized() print'resized win2' end
function win1:mouse_enter() print'mouse_enter win1' end
function win2:mouse_enter() print'mouse_enter win2' end
function win1:mouse_leave() print'mouse_leave win1' end
function win2:mouse_leave() print'mouse_leave win2' end
function win1:mouse_move() print('mouse_move win1', win1.mouse.x, win1.mouse.y) end
function win2:mouse_move() print('mouse_move win2', win2.mouse.x, win2.mouse.y) end
function win1:mouse_down(button, click_count) print('mouse_down win1', button) end
function win2:mouse_down(button, click_count) print('mouse_down win2', button) end
function win1:mouse_up(button, click_count) print('mouse_up win1', button) end
function win2:mouse_up(button, click_count) print('mouse_up win2', button) end
function win1:mouse_click(button, click_count)
	print('mouse_click win1', button, click_count)
	if click_count == 2 then return true end
end
function win2:mouse_click(button, click_count)
	print('mouse_click win2', button, click_count)
	if click_count == 3 then return true end
end
function win1:mouse_wheel(delta) print('mouse_wheel win1', delta) end
function win2:mouse_wheel(delta) print('mouse_wheel win2', delta) end

local commands = {
	Q = function(self) win1:state(win1:state() == 'maximized' and 'normal' or 'maximized') end,
	W = function(self) win1:show'maximized' end,
	E = function(self) if win1:visible() then win1:hide() else win1:show() end end,
	R = function(self) self:frame('allow_resize', not self:frame'allow_resize') end,

	F11 = function(self)
		win1:fullscreen(not win1:fullscreen())
	end,

	left = function(self) local x, y, w, h = self:frame_rect(); x = x - 100; self:frame_rect(x, y, w, h) end,
	right = function(self) local x, y, w, h = self:frame_rect(); x = x + 100; self:frame_rect(x, y, w, h) end,
	up = function(self) local x, y, w, h = self:frame_rect(); y = y - 100; self:frame_rect(x, y, w, h) end,
	down = function(self) local x, y, w, h = self:frame_rect(); y = y + 100; self:frame_rect(x, y, w, h) end,

	space = function(self)
		local state = self:state()
		if self:state() == 'maximized' then
			self:show'normal'
		elseif self:state() == 'normal' then
			self:show'minimized'
		elseif self:state() == 'minimized' then
			self:show'maximized'
		end
		print('state', state, '->', self:state())
	end,
	esc = function(self)
		if win2:active() then
			win1:activate()
		elseif win1:active() then
			win2:activate()
		end
	end,
	H = function(self)
		if self:visible() then
			self:hide()
		else
			self:show()
		end
	end,
	M = function(self)
		app:window{x = 200, y = 200, w = 200, h = 200, title = 'temp', visible = true, state = 'minimized'}
	end,
	shift = function(self)
		print('shift-key', self:key'lshift' and 'left' or 'right')
	end,
	alt = function(self)
		print('alt-key', self:key'lalt' and 'left' or 'right')
	end,
	ctrl = function(self)
		print('ctrl-key', self:key'lctrl' and 'left' or 'right')
	end,
}

function win2:key_press(key)
	print('key_press', key, win2:key(key))
	if commands[key] then
		commands[key](self)
	end
end

function win2:key_down(key)
	print('key_down', key, self:key(key))
end

win1.key_down = win2.key_down
win1.key_press = win2.key_press

function win2:key_up(key)
	print('key_up', key, win2:key(key))
end

function win2:key_char(char) print('key_char', char) end

win1:show()
win2:show()

app:run()

assert(win1:dead())
assert(win2:dead())

win1:free() --ignored
win2:free() --ignored
