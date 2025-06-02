-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- Change font weight
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
-- MacOS font
if wezterm.target_triple == "aarch64-apple-darwin" then
	config.font = wezterm.font("Lilex Nerd Font")
end

-- For example, changing the color scheme:
--config.color_scheme = 'Apprentice (Gogh)'
--config.color_scheme = "Chalk"
-- config.color_scheme = "OneHalDark"
config.color_scheme = "Eighties (base16)"

-- config.keys = {
--   -- paste from the clipboard
--   { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
--
--   -- paste from the primary selection
--   { key = 'v', mods = 'CTRL', action = act.PasteFrom 'PrimarySelection' },
-- }

-- launch menu for different shell
local launch_menu = {}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	table.insert(launch_menu, {
		label = "PowerShell",
		args = { "pwsh.exe", "-NoLogo" },
	})

	-- Find installed visual studio version(s) and add their compilation
	-- environment command prompts to the menu
	for _, vsvers in ipairs(wezterm.glob("Microsoft Visual Studio/20*", "F:/Program Files (x86)")) do
		local year = vsvers:gsub("Microsoft Visual Studio/", "")
		table.insert(launch_menu, {
			label = "x64 Native Tools VS " .. year,
			args = {
				"cmd.exe",
				"/k",
				"F:/Program Files (x86)/" .. vsvers .. "/BuildTools/VC/Auxiliary/Build/vcvars64.bat",
			},
		})
	end

	-- insert conda profile
	table.insert(launch_menu, {
		label = "Conda (base)",
		args = {
			"powershell.exe",
			"-NoExit",
			--'"',
			"C:/Users/Heiser/miniconda3/Scripts/conda.exe",
			"shell.powershell",
			"hook",
			"| Out-String | Invoke-Expression",
			--'"',
		},
	})
end
config.launch_menu = launch_menu

-- QuickSelect Patterns
config.quick_select_patterns = {
	-- Kubernetes resources
	"\\b[a-z0-9]+(?:-[a-z0-9]+)*-[0-9a-f]{8,10}-[a-z0-9]{5}",
}

-- Copy Mode Configs
local copy_mode = nil
if wezterm.gui then
	copy_mode = wezterm.gui.default_key_tables().copy_mode
	-- Yank and Paste
	table.insert(copy_mode, {
		key = "Y",
		mods = "NONE",
		action = act.Multiple({
			{ CopyTo = "ClipboardAndPrimarySelection" },
			act.ScrollToBottom,
			{ CopyMode = "ClearPattern" },
			{ CopyMode = "Close" },
			act.PasteFrom("PrimarySelection"),
		}),
	})
	-- Clear Search Pattern after yanking
	table.insert(copy_mode, {
		key = "y",
		mods = "NONE",
		action = act.Multiple({
			{ CopyTo = "ClipboardAndPrimarySelection" },
			act.ScrollToBottom,
			{ CopyMode = "ClearPattern" },
			{ CopyMode = "Close" },
		}),
	})
end

config.key_tables = {
	copy_mode = copy_mode,
}

-- and finally, return the configuration to wezterm
return config
