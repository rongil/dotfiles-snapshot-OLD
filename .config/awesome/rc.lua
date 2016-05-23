-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Vicious Widgets
local vicious = require("vicious")
-- Lain Widgets
local lain = require("lain")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/powerarrow-darker/theme.lua")
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- Autorun programs
local autorunApps = {
  ["dropbox"] = "",
  ["parcellite"] = "-n",
  ["redshift"] = "",
  ["xautolock"] =
    -- Timer and wallpaper
    [[-time 10 -locker 'i3lock -dfi ]] .. beautiful.wallpaper .. [[' ]] ..
    -- Notify of the screen locking
    [[-notify 15 -notifier 'notify-send -t 10000 -i ]] .. beautiful.lock .. [[ "Screen is about to lock..."' ]] ..
    -- Suspend the system 10 minutes (minimum time for killtime) after it locks
    -- unless user activity is detected
    [[-killtime 10 -killer 'systemctl suspend' ]] ..
    -- Top left corner disables temporarily and bottom left activates immediately
    [[-corners -0+0 -cornerdelay 5 -cornerredelay 5 ]]
}
for app, args in pairs(autorunApps) do
  awful.util.spawn_with_shell(
    " if (( ! $(pgrep -cx '" .. app .. "') )); then " .. app .. " " .. args .. "; fi "
  )
end

-- {{ Powerarrow-dark separators }} --
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- TODO: Needs to be set to computer's specific eth/wifi interface
local ETH_INTERFACE = "REDACTED"
local WIFI_INTERFACE = "REDACTED"
local CURRENT_INTERFACE = ""

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"
notmodkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

-- Special floating window behavior
awful.button({ modkey }, 1,
    function (c)
         c.maximized_horizontal = false
         c.maximized_vertical   = false
         c.maximized            = false
         c.fullscreen           = false
         awful.mouse.client.move(c)
    end)

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9}, s, {
      layouts[3], layouts[4], layouts[4], layouts[3], layouts[4], layouts[3], layouts[4], layouts[4], layouts[3]
    })
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

-- Create a textclock widget
mytextclock = awful.widget.textclock()

--{{-- Time and Date Widget }} --
tdwidget = wibox.widget.textbox()
vicious.register(tdwidget, vicious.widgets.date, '<span> %a %b %d %I:%M </span>', 20)
-- Attach Calendar Widget to time/date
lain.widgets.calendar:attach(tdwidget)

--{{ Battery Widget }} --
batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, '<span> $1 $2% </span>', 30, "BAT0")

--{{ Net Widget }} --
netwidget = wibox.widget.textbox()
neticon = wibox.widget.imagebox()
vicious.register(netwidget, vicious.widgets.net, function(widgets,args)
    if args["{" .. WIFI_INTERFACE .. " carrier}"] == 1 then
        CURRENT_INTERFACE = WIFI_INTERFACE
    elseif args["{" .. ETH_INTERFACE .. " carrier}"] == 1 then
        CURRENT_INTERFACE = ETH_INTERFACE
    else
        return ""
    end
    return '<span>' .. args["{".. CURRENT_INTERFACE .." down_kb}"] .. " " .. args["{" .. CURRENT_INTERFACE .. " up_kb}"] .. ' </span>' end, 5)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1, function() awful.util.spawn_with_shell('wicd-client -n') end)))

---{{---| Wifi Signal Widget |-------
vicious.register(neticon, vicious.widgets.wifi, function(widget, args)
    local sigstrength = tonumber(args["{link}"])
    -- Show ethernet icon instead if using ethernet
    if CURRENT_INTERFACE == ETH_INTERFACE then
        neticon:set_image(beautiful.neteth)
    elseif sigstrength > 55 then
        neticon:set_image(beautiful.nethigh)
    elseif sigstrength > 30 and sigstrength < 55 then
        neticon:set_image(beautiful.netmed)
    elseif sigstrength > 0 then
        neticon:set_image(beautiful.netlow)
    else
        neticon:set_image(beautiful.netnone)
    end
end, 5, WIFI_INTERFACE)

-- {{ Volume Widget }} --
volume = wibox.widget.textbox()
vicious.register(volume, vicious.widgets.volume, '<span>$1 </span>', 0.2, "Master")
volumeicon = wibox.widget.imagebox()
vicious.register(volumeicon, vicious.widgets.volume, function(widget, args)
        local paraone = tonumber(args[1])

        if args[2] == "♩" or paraone == 0 then
                volumeicon:set_image(beautiful.vol_mute)
        elseif paraone >= 67 and paraone <= 100 then
                volumeicon:set_image(beautiful.vol_high)
        elseif paraone >= 33 and paraone <= 66 then
                volumeicon:set_image(beautiful.vol_med)
        else
                volumeicon:set_image(beautiful.vol_low)
        end
end, 0.3, "Master")

--{{--| MEM widget |-----------------
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, '<span> <span>$2MB $5MB </span></span>', 20)
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.mem)

--{{---| CPU / sensors widget |-----------
cpuwidget = wibox.widget.textbox()
thermalwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu,
'<span> $1%</span>', 5)
vicious.register(thermalwidget, vicious.widgets.thermal,
'<span> $1°C </span>', 5, "thermal_zone0")
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.cpu)

-- My first widgets :)
-- ----------------------------------------------------------------------------
---- Widget separation
separator_space = wibox.widget.textbox()
--separator = wibox.widget.textbox()
separator_space:set_text(" ")
--separator:set_text(" :: ")

---- Initialize widget
--memwidget = wibox.widget.textbox()
---- Register widget
--vicious.register(memwidget, vicious.widgets.mem, "($2MB/$3MB)", 10)
--
---- Initialize widget
--cpuwidget = wibox.widget.textbox()
---- Register widget
--vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")
--
----  Network usage widget
-- -- Initialize widget
-- netwidget = wibox.widget.textbox()
-- -- Register widget
-- vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${WIFI_INTERFACE down_kb}</span> <span color="#7F9F7F">${WIFI_INTERFACE up_kb}</span>', 3)
--
---- Create a textclock widget
--mytextclock = awful.widget.textclock("%a %d %b, %I:%M")
-- ----------------------------------------------------------------------------

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(separator_space)
    right_layout:add(arrl_dl)
    right_layout:add(memicon)
    right_layout:add(memwidget)
    right_layout:add(arrl_dl)
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)
    right_layout:add(thermalwidget)
    right_layout:add(arrl_dl)
    right_layout:add(volumeicon)
    right_layout:add(volume)
    right_layout:add(arrl_dl)
    right_layout:add(batwidget)
    right_layout:add(arrl_dl)
    right_layout:add(neticon)
    right_layout:add(netwidget)
    right_layout:add(arrl_dl)
    right_layout:add(tdwidget)
    right_layout:add(arrl_dl)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- Compose Key
awful.util.spawn("setxkbmap -option compose:ralt")

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "h",      awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "l",      awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, ",",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, ".",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),

    -- Volume Keys
    awful.key({ }, "#121", function () awful.util.spawn_with_shell("amixer -q sset Master toggle") end),
    awful.key({ }, "#122", function () awful.util.spawn_with_shell("amixer -q sset Master 3- unmute") end),
    awful.key({ }, "#123", function () awful.util.spawn_with_shell("amixer -q sset Master 3+ unmute") end),

    -- Print Screen
    awful.key({ }, "Print",
        function ()
            awful.util.spawn_with_shell("import -window root screenshot_$(date +%F_%H-%M-%S).png")
        end),
    awful.key({ "Shift" }, "Print",
        function ()
            awful.util.spawn_with_shell("import screenshot_$(date +%F_%H-%M-%S).png")
        end),

    -- Show Calendar
    awful.key({ notmodkey }, "c", function () lain.widgets.calendar:show(7) end),

    -- Lock Screen
    awful.key({ notmodkey }, "l", function () awful.util.spawn("sctrl lock") end),

    -- Turn off screen
    awful.key({ notmodkey }, "d", function () awful.util.spawn("sctrl suspend") end),

    -- Toggle screen locking and dimming
    awful.key({ notmodkey }, "s", function () awful.util.spawn("sctrl toggle") end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))
-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } }
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
