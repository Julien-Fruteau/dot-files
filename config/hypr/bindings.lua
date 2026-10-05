-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
o.bind("SUPER + E", "Open File Explorer", "nautilus")

-- Move the close-window shortcut from Super+W to Super+Q.
-- hl.unbind("SUPER + W")
-- o.bind("SUPER + Q", "Close window", "hyprctl dispatch killactive")

-- Noctalia/Niri-style window navigation and movement.
-- Preserve the Omarchy actions displaced by these shortcuts on alternate keys.
hl.unbind("SUPER + L")
hl.unbind("SUPER + code:20")
hl.unbind("SUPER + code:21")
-- hl.unbind("SUPER + CTRL + code:20")
-- hl.unbind("SUPER + CTRL + code:21")
-- Leave Ctrl+Alt+H/L available to Kitty.
hl.unbind("CTRL + ALT + H")
hl.unbind("CTRL + ALT + L")
hl.unbind("CTRL + ALT + J")
hl.unbind("CTRL + ALT + K")

hl.unbind("SHIFT + ALT + J")
hl.unbind("SHIFT + ALT + K")
hl.unbind("SUPER + ALT + L")
hl.unbind("SUPER + CTRL + H")
hl.unbind("SUPER + CTRL + L")
o.bind("SUPER + ALT + SHIFT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + ALT + L", "Lock system", "omarchy-system-lock")
-- Replace Super +/- resizing with scrolling column resizing.
-- Disable the former Super+Shift +/- shortcuts, including default keycodes.
hl.unbind("SUPER + SHIFT + code:20")
hl.unbind("SUPER + SHIFT + code:21")
hl.unbind("SUPER + SHIFT + MINUS")
hl.unbind("SUPER + SHIFT + EQUAL")
hl.unbind("SUPER + MINUS")
hl.unbind("SUPER + EQUAL")
hl.unbind("SUPER + CTRL + code:20")
hl.unbind("SUPER + CTRL + code:21")
-- hl.unbind("SUPER + CTRL + MINUS")
-- hl.unbind("SUPER + CTRL + EQUAL")
o.bind("SUPER + EQUAL", "Expand scrolling column", function()
  hl.dispatch(hl.dsp.layout("colresize +0.05"))
  hl.dispatch(hl.dsp.layout("fit_into_view"))
end)
o.bind("SUPER + MINUS", "Shrink scrolling column", function()
  hl.dispatch(hl.dsp.layout("colresize -0.05"))
  hl.dispatch(hl.dsp.layout("fit_into_view"))
end)

hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Center current column", hl.dsp.layout("center"))


o.bind("SUPER + H", "Focus window left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus window right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + BRACKETLEFT", "Move window into group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + BRACKETRIGHT", "Move window into group on right", hl.dsp.window.move({ into_group = "r" }))
o.bind("SUPER + CTRL + H", "Move window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + CTRL + L", "Move window right", hl.dsp.window.swap({ direction = "r" }))

-- Swap full screen and full width shortcuts.
-- Cycle window focus while maximized or fullscreen.
hl.config({ binds = { movefocus_cycles_fullscreen = true } })

hl.unbind("SUPER + F")
hl.unbind("SUPER + ALT + F")
o.bind("SUPER + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
