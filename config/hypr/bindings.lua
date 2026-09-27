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
-- hl.unbind("SUPER + code:20")
-- hl.unbind("SUPER + code:21")
-- hl.unbind("SUPER + CTRL + code:20")
-- hl.unbind("SUPER + CTRL + code:21")
hl.unbind("SUPER + CTRL + H")
hl.unbind("SUPER + CTRL + L")

o.bind("SUPER + ALT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + CTRL + MINUS", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("SUPER + CTRL + EQUAL", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
o.bind("CTRL + ALT + H", "Hardware menu", "omarchy-menu toggle hardware")
o.bind("CTRL + ALT + L", "Lock system", "omarchy-system-lock")

o.bind("SUPER + H", "Focus window left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus window right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + BRACKETLEFT", "Move window into group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + BRACKETRIGHT", "Move window into group on right", hl.dsp.window.move({ into_group = "r" }))
o.bind("SUPER + CTRL + H", "Move window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + CTRL + L", "Move window right", hl.dsp.window.swap({ direction = "r" }))
