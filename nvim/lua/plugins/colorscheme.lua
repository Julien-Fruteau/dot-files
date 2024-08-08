return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "macchiato"
    }, -- latte, frappe, macchiato, mocha }
    lazy = false
}, {
    "navarasu/onedark.nvim",
    priority = 1000,
    lazy = false
}, {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false
}, {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    lazy = false,
    priority = 1000
}, {
    "romainl/Apprentice",
    priority = 1000
}, {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
        style = "storm"
    }, -- storm, night, moon, day
    lazy = false
}, {"drewtempelmeyer/palenight.vim"}, {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
    opts = ...
}, -- Using lazy.nvim
{
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000
}, {
    "nordtheme/vim",
    lazy = false,
    priority = 1000
}, {
    "mhartington/oceanic-next",
    lazy = false,
    priority = 1000
}, {
    "roobert/palette.nvim",
    lazy = false,
    priority = 1000,
    -- config = function()
    -- 	vim.cmd("colorscheme palette")
    -- end,
    config = function()
        require("palette").setup({
            palettes = {
                -- built in colorscheme: grey
                main = "dust_dusk",
                -- built in accents: pastel, bright, dark
                accent = "pastel",
                state = "pastel"
            },

            italics = true,
            transparent_background = false,

            custom_palettes = {
                main = {
                    dust_dusk = {
                        color0 = "#121527",
                        color1 = "#1A1E39",
                        color2 = "#232A4D",
                        color3 = "#3E4D89",
                        color4 = "#687BBA",
                        color5 = "#A4B1D6",
                        color6 = "#bdbfc9",
                        color7 = "#DFE5F1",
                        color8 = "#e9e9ed"
                    }
                }
            },
            accent = {},
            state = {}
        })

    end
}, {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000
}, {
    "EdenEast/nightfox.nvim",
    priority = 1000
}}
