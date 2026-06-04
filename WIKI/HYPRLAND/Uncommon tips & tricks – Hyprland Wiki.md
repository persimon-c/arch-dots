Configuring Advanced and Cool Uncommon tips & tricks 

Uncommon tips & tricks 

Remapping Caps Lock 

You can customize the behavior of the Caps Lock key using kb\_options . 

To view all available options related to Caps Lock, run: 

grep 'caps' /usr/share/X11/xkb/rules/base.lst 

For example, to remap Caps lock to Ctrl: 

hl.config({ 

input **\=** { 

kb\_options **\=** "ctrl:nocaps", 

}, 

}) 

You can find additional kb\_options unrelated to Caps Lock in /usr/share/X11/xkb/rules/base.lst . Minimize windows using special workspaces 

This approach uses special workspaces to mimic the “minimize window” function, by using a single keybind to toggle the minimized state. Note that one keybind can only handle one window. 

hl.bind("SUPER \+ X", **function** () 

hl.dispatch(hl.dsp.workspace.toggle\_special("minimize")) 

hl.dispatch(hl.dsp.window.move({workspace **\=** "+0"})) 

hl.dispatch(hl.dsp.workspace.toggle\_special("minimize")) 

hl.dispatch(hl.dsp.window.move({workspace **\=** "special:minimize"})) 

hl.dispatch(hl.dsp.workspace.toggle\_special("minimize")) 

**end**) 

Toggle animations/blur/etc hotkey 

For less distractions at a keypress, or battery saving on a laptop 

Add the following to your hyprland config: 

hl.bind("SUPER \+ F1", **function** () 

**local** game\_mode **\=** (hl.get\_config("animations.enabled") **\== false**) 

**if** game\_mode **then** 

hl.exec\_cmd("hyprctl reload") 

**return** 

**end** 

hl.config({ 

general **\=** { 

gaps\_in **\=** 0, gaps\_out **\=** 0, \-- Disable gaps 

border\_size **\=** 0, 

}, 

animations **\=** { 

enabled **\= false**, \-- Disable animations 

}, 

\-- Disable blur, shadow and window rounding  
decoration **\=** { 

shadow **\=** { enabled **\= false** }, 

blur **\=** { enabled **\= false** }, 

rounding **\=** 0, 

} 

}) 

**end**) 

Edit to your liking of course. If animations are enabled, it disables all the pretty stuff. Otherwise, the script reloads your config to grab your defaults. 

Per workspace layouts 

You can use workspace rules to set per-workspace layouts: 

hl.workspace\_rule({ workspace **\=** "2", layout **\=** "scrolling" }) 

hl.workspace\_rule({ workspace **\=** "3", layout **\=** "dwindle" }) 

Cycle layout for current workspace 

To change layout for current workspace you can use this bind: 

hl.bind("SUPER \+ tab", **function** () 

**local** layouts **\=** { "scrolling", "dwindle", "master", "monocle" } 

**local** workspace **\=** hl.get\_active\_workspace() 

**local** next\_layout **\=** "dwindle" 

**if not** workspace **then** 

**return** 

**end** 

**for** i **\=** 1, **\#**layouts **do** 

**if** layouts\[i\] **\==** workspace.tiled\_layout **then** 

**local** next\_layout\_idx **\=** (i **% \#**layouts) **\+** 1 

next\_layout **\=** layouts\[next\_layout\_idx\] 

**break** 

**end** 

**end** 

hl.workspace\_rule({ workspace **\=** workspace.name, layout **\=** next\_layout }) 

**end**) 

Per layout bindings 

Use this one to bind different actions to the same key binding based on current layout: 

**local function layout\_bind**(bind\_table) 

**return function** () 

**local** workspace **\=** hl.get\_active\_special\_workspace() **or** 

hl.get\_active\_workspace() 

**if not** workspace **then** 

**return** 

**end** 

**local** layout **\=** workspace.tiled\_layout 

**if** bind\_table\[layout\] **then** 

hl.dispatch(bind\_table\[layout\]) 

**end** 

**end** 

**end** 

hl.bind("SUPER \+ A", layout\_bind({  
scrolling **\=** hl.dsp.layout("swapcol l"), \-- Scrolling: swap column with left one dwindle **\=** hl.dsp.layout("swapsplit"), \-- Dwindle: swap window split 

monocle **\=** hl.dsp.layout("cycleprev"), \-- Monocle and master: cycle prev window master **\=** hl.dsp.layout("cycleprev"), 

})) 

hl.bind("SUPER \+ D", layout\_bind({ 

scrolling **\=** hl.dsp.layout("swapcol r"), \-- Scrolling: swap column with right one dwindle **\=** hl.dsp.layout("togglesplit"), \-- Dwindle: toggle window split monocle **\=** hl.dsp.layout("cyclenext"), \-- Monocle and master: cycle next window master **\=** hl.dsp.layout("cyclenext"), 

})) 

Config versioning 

Some updates add breaking changes, which can be anticipated by looking at the hyprland version. You can make your configs conditional using hl.version() , e.g.: 

**if** hl.version() **\==** "0.55.2" **then** 

hl.config({ 

general **\=** { 

changed\_property **\=** "value" 

} 

}) 

**else** 

hl.notification.create({ 

text **\=** "Youre using: "**..** hl.version(), 

timeout **\=** 10000 

}) 

**end** 

Glass magnifier zoom 

Bind to use cursor zoom like a glass magnifier 

**local** MAX\_ZOOM **\=** 3 

**local** MIN\_ZOOM **\=** 1 

**local** ZOOM\_TOGGLE\_FACTOR **\=** 1.5 

\---@param offset number 

\---@return nil 

**local function zoom**(offset) 

**local** current **\=** hl.get\_config("cursor.zoom\_factor") 

**if** offset **\~= nil then** 

current **\=** current **\+** offset 

**elseif** current **\~=** MIN\_ZOOM **then** 

current **\=** MIN\_ZOOM 

**else** 

current **\=** ZOOM\_TOGGLE\_FACTOR 

**end** 

current **\=** math.max(MIN\_ZOOM, math.min(MAX\_ZOOM, current)) 

hl.config({ cursor **\=** { zoom\_factor **\=** current } }) 

**end** 

hl.bind("SUPER \+ Z", zoom) 

hl.bind("SUPER \+ KP\_ADD", **function**() 

zoom(0.5) 

**end**) 

hl.bind("SUPER \+ minus", **function**() 

zoom(**\-**0.5) 

**end**)

Last updated on June 2, 2026 