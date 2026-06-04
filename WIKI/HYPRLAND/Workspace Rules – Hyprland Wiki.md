Configuring Basics Workspace Rules 

Workspace Rules 

Note 

Looking for the old hyprlang syntax? Check the 0.54 wiki pages. Since Hyprland 0.55, hyprlang is deprecated in favor of lua. 

You can set workspace rules to achieve workspace-specific behaviors. For instance, you can define a workspace where all windows are drawn without borders or gaps. 

For layout-specific rules, see the specific layout page. For example: Master Layout-\>Workspace Rules. Syntax 

hl.workspace\_rule(workspace, rule1, rule2, ...)

WORKSPACE is a valid workspace identifier (see Dispatchers-\>Workspaces). This field is mandatory. This can be a workspace selector, but please note workspace selectors can only match existing workspaces. 

RULES is one (or more) rule(s) as described here in rules. 

Workspace selectors 

Workspaces that have already been created can be targeted by workspace selectors, e.g. r\[2-4\] w\[t1\] . Selectors have props separated by a space. No spaces are allowed inside props themselves. Props: 

r\[A-B\] \- ID range from A to B inclusive 

s\[bool\] \- Whether the workspace is special or not 

n\[bool\] , n\[s:string\] , n\[e:string\] \- named actions. n\[bool\] \-\> whether a workspace is a named workspace, s and e are starts and ends with respectively 

m\[monitor\] \- Monitor selector 

w\[(flags)A-B\] , w\[(flags)X\] \- Prop for window counts on the workspace. A-B is an inclusive range, X is a specific number. Flags can be omitted. It can be t for tiled-only, f for floating-only, g to count groups instead of windows, v to count only visible windows, and p to count only pinned windows. 

f\[-1\] , f\[0\] , f\[1\] , f\[2\] \- fullscreen state of the workspace. \-1 : no fullscreen, 0 : fullscreen, 1 : maximized, 2 , fullscreen without fullscreen state sent to the window. 

Rules 

| Rule  | Description  | type |
| ----- | ----- | ----- |
| monitor  | Binds a workspace to a monitor. See syntax and Monitors.  | string |
| default  | Whether this workspace should be the default workspace for the given monitor  | bool |
| gaps\_in  | Set the gaps between windows (equivalent to General-\>gaps\_in)  | int |
| gaps\_out  | Set the gaps between windows and monitor edges (equivalent to General-\>gaps\_out)  | int |
| border\_size  | Set the border size around windows (equivalent to General-\>border\_size)  | int |
| no\_border  | Whether to disable borders  | bool |
| no\_shadow  | Whether to disable shadows  | bool |

| Rule  | Description  | type |
| ----- | ----- | :---: |
| no\_rounding  | Whether to disable rounded windows  | bool |
| decorate  | Whether to draw window decorations or not  | bool |
| persistent  | Keep this workspace alive even if empty and inactive  | bool |
| on\_created\_empty | A command to be executed once a workspace is created empty (i.e. not created by moving a window to it). See the command syntax | string |
| default\_name  | A default name for the workspace.  | string |
| layout  | The layout to use for this workspace.  | string |
| animation  | The animation style to use for this workspace.  | string |

Examples 

hl.workspace\_rule({ workspace **\=** "3", no\_rounding **\= true**, decorate **\= false** }) 

hl.workspace\_rule({ workspace **\=** "name:coding", no\_rounding **\= true**, decorate **\= false**, gaps\_in **\=** 0, gaps\_ou hl.workspace\_rule({ workspace **\=** "8", border\_size **\=** 8 }) 

hl.workspace\_rule({ workspace **\=** "name:Hello", monitor **\=** "DP-1", default **\= true** }) hl.workspace\_rule({ workspace **\=** "name:gaming", monitor **\=** "desc:Chimei Innolux Corporation 0x150C", defaul hl.workspace\_rule({ workspace **\=** "5", on\_created\_empty **\=** "\[float\] firefox" }) 

hl.workspace\_rule({ workspace **\=** "special:scratchpad", on\_created\_empty **\=** "foot" }) hl.workspace\_rule({ workspace **\=** "15", animation **\=** "slidevert", default\_name **\=** "slider" }) 

Smart gaps 

To replicate “smart gaps” / “no gaps when only” from other WMs/Compositors, use this bad boy: 

hl.workspace\_rule({ workspace **\=** "w\[tv1\]", gaps\_out **\=** 0, gaps\_in **\=** 0 }) 

hl.workspace\_rule({ workspace **\=** "f\[1\]", gaps\_out **\=** 0, gaps\_in **\=** 0 }) 

hl.window\_rule({ match **\=** { float **\= false**, workspace **\=** "w\[tv1\]" }, border\_size **\=** 0 }) hl.window\_rule({ match **\=** { float **\= false**, workspace **\=** "w\[tv1\]" }, rounding **\=** 0 }) hl.window\_rule({ match **\=** { float **\= false**, workspace **\=** "f\[1\]" }, border\_size **\=** 0 }) hl.window\_rule({ match **\=** { float **\= false**, workspace **\=** "f\[1\]" }, rounding **\=** 0 }) 

Smart gaps (ignoring special workspaces) 

You can combine workspace selectors for more fine-grained control, for example, to ignore special workspaces: 

hl.workspace\_rule({ workspace **\=** "w\[tv1\]s\[false\]", gaps\_out **\=** 0, gaps\_in **\=** 0 }) 

hl.workspace\_rule({ workspace **\=** "f\[1\]s\[false\]", gaps\_out **\=** 0, gaps\_in **\=** 0 }) 

hl.window\_rule({ match **\=** { float **\= false**, workspace **\=** "w\[tv1\]s\[false\]" }, border\_size **\=** 0 }) hl.window\_rule({ match **\=** { float **\= false**, workspace **\=** "w\[tv1\]s\[false\]" }, rounding **\=** 0 }) hl.window\_rule({ match **\=** { float **\= false**, workspace **\=** "f\[1\]s\[false\]" }, border\_size **\=** 0 }) hl.window\_rule({ match **\=** { float **\= false**, workspace **\=** "f\[1\]s\[false\]" }, rounding **\=** 0 }) 

Per-workspace layouts 

Use workspace rules to set per-workspace layouts: 

hl.workspace\_rule({ workspace **\=** "2", layout **\=** "scrolling" })

Last updated on June 2, 2026 