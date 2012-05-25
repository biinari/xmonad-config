import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops (fullscreenEventHook)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Renamed
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiColumns
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.Reflect
import XMonad.Layout.PerWorkspace
import XMonad.Layout.LayoutHints
import XMonad.Util.Run (safeSpawn,spawnPipe)
import XMonad.Util.EZConfig (additionalKeysP)
import Data.List
import Data.Monoid (mappend)
import Data.Ratio ((%))
import System.IO
import qualified XMonad.StackSet as W

modm = mod1Mask

myManageHook = composeAll . concat $
	[ [ className =? c --> doFloat | c <- myClassFloats ]
	, [ (className =? c <&&> title =? t) --> doShift "9"
		| (c,t) <- myIMRosters ]
	, [ className =? "Rhythmbox" --> doShift "0" ]
	, [ className =? c --> doShift "=" | c <- gimpClass ]
	, [ className =? "Firefox" <&&> title =? "Downloads" --> doFloat ]
	, gimp "toolbox" unfloat
	, gimp "image-window" unfloat
	, gimp "dock" unfloat
	, [ manageDocks ]
	-- Allow focussing other monitors without killing the fullscreen
	, [ isFullscreen --> (doF W.focusDown <+> doFullFloat) ]
	]
	where
		myClassFloats = ["Xmessage", "Gxmessage", "Gnome-font-viewer"]
		gimpClass = ["Gimp", "Gimp-2.6"]
		myIMRosters = [ ("Skype", "bill.ruddock - Skype™ (Beta)")
					  , ("Skype", "Skype™ 2.2 (Beta) for Linux")
					  , ("Pidgin", "Buddy List")
					  ]
		unfloat = ask >>= doF . W.sink
		gimp win action = [ className =? c <&&> fmap (win `isSuffixOf`) role --> action
							| c <- gimpClass ]
		role = stringProperty "WM_WINDOW_ROLE"

myWorkspaces = map show [1 .. 9] ++ ["0","-","=","`"]

-- Default number of windows in master pane
layoutNMaster = 1
-- Default proportion of screen occupied by master
layoutRatio = 1/2
-- Percent of screen to increment by when resizing
layoutDelta = 1/182

tiledPart = Tall layoutNMaster layoutDelta layoutRatio

multiLayout = avoidStruts $ multi ||| Mirror multi ||| Full
	where
		multi = multiCol [layoutNMaster,3,0] 0 layoutDelta (-1 * layoutRatio)

tiledLayout = avoidStruts $ tiledPart ||| Mirror tiledPart ||| Full

midLayout = avoidStruts $ ThreeColMid layoutNMaster layoutDelta (5/11)

imLayout = avoidStruts $ renamed [CutWordsLeft 2] $
		   withIM (1%6) (Title skypeTitle1 `Or` Title skypeTitle2) $
		   reflectHoriz $ withIM (1%5) (Role "buddy_list") $
		   Grid ||| tiledPart
		   where
				skypeTitle1 = "Skype™ 2.2 (Beta) for Linux"
				skypeTitle2 = "bill.ruddock - Skype™ (Beta)"

gimpLayout = avoidStruts $ renamed [CutWordsLeft 3, Prepend "Gimp "] $
			 withIM 0.11 (Role "gimp-toolbox") $
			 reflectHoriz $ withIM 0.15 (Role "gimp-dock") $
			 Full ||| tiledPart

vboxLayout = Full

myKeys =
	[ ("M-S-l", spawn "xscreensaver-command -lock")
	, ("<XF86ScreenSaver>", spawn "xscreensaver-command -lock")
	, ("C-<Print>", spawn "sleep 0.2; scrot -s")
	, ("<Print>", spawn "scrot")
	, ("M-S-f", spawn "firefox")
	, ("M-S-g", spawn "google-chrome")
	, ("M-S-v", spawn "gvim")
	, ("M-b", sendMessage ToggleStruts)
	, ("<XF86AudioStop>", spawn "rhythmbox-client --pause --no-present --no-start")
	, ("<XF86AudioNext>", spawn "rhythmbox-client --next --no-present --no-start")
	, ("<XF86AudioPlay>", spawn "rhythmbox-client --play-pause --no-present")
	, ("<XF86AudioPrev>", spawn "rhythmbox-client --previous --no-present --no-start")
	, ("<XF86AudioMute>", spawn "sound_toggle.sh")
	, ("<XF86AudioLowerVolume>", spawn "amixer set Master 2%- unmute")
	, ("<XF86AudioRaiseVolume>", spawn "amixer set Master 2%+ unmute")
	, ("<XF86Sleep>", spawn "sudo pm-suspend")
	, ("<XF86PowerOff>", spawn "/home/bill/.xmonad/shutdown_confirm.sh")
	] ++
	-- non greedy view to avoid swapping visible workspaces
	[ (otherModMasks ++ "M-" ++ [key], windows $ action tag)
	  | (tag, key) <- zip myWorkspaces "1234567890-=`"
	  , (otherModMasks, action) <- [ ("", W.view)
								   , ("S-", W.shift)]
	]

boringWorkspaces :: [String]
boringWorkspaces = ["0","-","`"]

main = do
	xmproc <- spawnPipe "xmobar /home/billarch/.xmobarrc"
	xmonad $ defaultConfig
		{ terminal = "lxterminal"
		, focusedBorderColor = "#8bcd00"
		, focusFollowsMouse = False
		-- Focus and pass click to window. Needs the patch from
		-- http://code.google.com/p/xmonad/issues/detail?id=225
		, clickJustFocuses = False
		, modMask = modm
		, workspaces = myWorkspaces
		, manageHook = myManageHook <+> manageHook defaultConfig
		, layoutHook = smartBorders $
						onWorkspace "9" imLayout $
						onWorkspace "=" gimpLayout $
						onWorkspace "`" vboxLayout
						tiledLayout
		, handleEventHook = mappend docksEventHook fullscreenEventHook
		, logHook = dynamicLogWithPP xmobarPP
						{ ppOutput = hPutStrLn xmproc
						, ppTitle = xmobarColor "LightBlue" "" . shorten 80
						, ppHidden = \x -> if x `elem` boringWorkspaces then "" else x
						-- Uncomment to not report layout
						--, ppLayout = \x -> ""
						}
		} `additionalKeysP` myKeys
