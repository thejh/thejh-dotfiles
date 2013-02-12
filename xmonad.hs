-- modified tychon's xmonad config

import XMonad
import XMonad.Layout.PerWorkspace
import XMonad.Layout.SimplestFloat
import XMonad.Layout.NoBorders
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import XMonad.Hooks.UrgencyHook
-- for fullscreen
import qualified XMonad.StackSet as W
import Control.Monad
import Data.Monoid (All (All))
import XMonad.Actions.NoBorders
import XMonad.Actions.UpdatePointer

myManageHook = composeAll
    [ className =? "Gimp"  --> doFloat
    , className =? "Totem" --> doCenterFloat
    , className =? "VLC" --> doCenterFloat
    , (className =? "Pidgin" --> doShift "7:chat" )
    , (className =? "mutt"  --> doShift "7:chat" )
    , composeOne [ isFullscreen -?> doFullFloat ]
    ]

main = do
  xmproc <- spawnPipe "/usr/bin/xmobar /home/jann/.xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook defaultConfig
    { workspaces = ["1", "2", "3", "4", "5", "6", "7:chat", "8:float", "9:tmp"]
    , manageHook = manageDocks <+> myManageHook <+> manageHook defaultConfig
    , layoutHook = avoidStruts $ smartBorders $  onWorkspace "float" simplestFloat $ layoutHook defaultConfig
    , logHook    = dynamicLogWithPP xmobarPP
                   { ppOutput = hPutStrLn xmproc
                   , ppTitle = xmobarColor "green" "" . shorten 50
                   , ppUrgent = xmobarColor "yellow" "red" . xmobarStrip
                   } >> updatePointer (Relative 0.5 0.5)
    , modMask = mod4Mask
    , terminal = "xterm"
    , handleEventHook = evHook
    } `additionalKeys`
    [ --((mod4Mask .|. controlMask, xK_b ), withFocused toggleBorder),
    --  ((mod4Mask, xK_l), spawn "xscreensaver-command -lock") -- lock screen
    -- , ((mod4Mask .|. controlMask .|. shiftMask, xK_F12), spawn "suhelper poweroff")   -- shutdown
    -- , ((mod4Mask .|. shiftMask, xK_F11), spawn "suhelper hibernate")   -- hibernate
    -- , ((mod4Mask .|. shiftMask, xK_h), spawn "nautilus /home/hannes") -- open nautilus
      ((mod4Mask, xK_s), spawn "standby.sh") -- go to standby
    , ((mod4Mask .|. shiftMask, xK_s), spawn "suspend.sh") -- hibernate
    , ((mod4Mask .|. controlMask, xK_s), spawn "xset dpms force off") -- turn screen off
    -- , ((mod4Mask .|. shiftMask, xK_g), spawn "gedit")        -- open gedit
    -- , ((mod4Mask .|. shiftMask, xK_i), spawn "chromium")     -- open chromium
    -- , ((mod4Mask .|. shiftMask, xK_u), spawn "chromium --incognito")     -- open chromium in incognito mode
    , ((mod4Mask, xK_r), spawn "gnome-calculator")
    , ((mod4Mask, xK_m), spawn "sudo killall mplayer")
    , ((0, xK_Print), spawn "scrot")                         -- take screenshot
    , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s") -- take screenshot of window
    ]

-- Helper functions to fullscreen the window
fullFloat, tileWin :: Window -> X ()
fullFloat w = windows $ W.float w r
    where r = W.RationalRect 0 0 1 1
tileWin w = windows $ W.sink w

evHook :: Event -> X All
evHook (ClientMessageEvent _ _ _ dpy win typ dat) = do
  state <- getAtom "_NET_WM_STATE"
  fullsc <- getAtom "_NET_WM_STATE_FULLSCREEN"
  isFull <- runQuery isFullscreen win

  -- Constants for the _NET_WM_STATE protocol
  let remove = 0
      add = 1
      toggle = 2

      -- The ATOM property type for changeProperty
      ptype = 4 

      action = head dat

  when (typ == state && (fromIntegral fullsc) `elem` tail dat) $ do
    when (action == add || (action == toggle && not isFull)) $ do
         io $ changeProperty32 dpy win state ptype propModeReplace [fromIntegral fullsc]
         fullFloat win
         --toggleBorder win
    when (head dat == remove || (action == toggle && isFull)) $ do
         io $ changeProperty32 dpy win state ptype propModeReplace []
         tileWin win
         --toggleBorder win

  -- It shouldn't be necessary for xmonad to do anything more with this event
  return $ All False

evHook _ = return $ All True
