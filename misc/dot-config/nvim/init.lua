-- ~/.config/nvim/init.lua

-- 1) Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

-- 2) Plugin manager (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    if vim.fn.executable("git") ~= 1 then
        vim.notify("lazy.nvim not installed and git is missing; skipping plugin setup", vim.log.levels.WARN)
        return
    end
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Theme
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({ contrast = "hard" })
            vim.cmd.colorscheme("gruvbox")
        end
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function() require("lualine").setup({ options = { theme = "gruvbox" } }) end
    },

    -- File finder (replaces :Files)
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- File tree (replaces NERDTree)
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                disable_netrw = true,
                hijack_netrw = true,
                sync_root_with_cwd = true,
                respect_buf_cwd = true,
                update_focused_file = { enable = true, update_root = true },
                renderer = {
                    highlight_git = true,
                    indent_markers = { enable = true },
                    icons = { show = { file = true, folder = true, folder_arrow = true, git = true } },
                },
                diagnostics = { enable = true },
                git = { enable = true, ignore = false, show_on_dirs = true },
                filters = { dotfiles = false, custom = { ".DS_Store" } },
                view = { width = 34, side = "left", preserve_window_proportions = true },
            })

            -- Auto-close nvim if the tree is the last window
            vim.api.nvim_create_autocmd("BufEnter", {
                nested = true,
                callback = function()
                    if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
                        vim.cmd("quit")
                    end
                end,
            })

            -- If you start nvim with a directory, open the tree and cd into it
            local function open_nvim_tree(data)
                local is_dir = vim.fn.isdirectory(data.file) == 1
                if not is_dir then return end
                vim.cmd.cd(data.file)
                require("nvim-tree.api").tree.open()
            end
            vim.api.nvim_create_autocmd("VimEnter", { callback = open_nvim_tree })
        end,
    },

    -- Motion (replaces easymotion)
    { "smoka7/hop.nvim",         config = function() require("hop").setup() end },

    -- Git signs (replaces gitgutter)
    { "lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup() end },

    -- Treesitter (modern syntax/indent)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

})

-- 3) Keymaps (mirror your habits)
local map = vim.keymap.set
-- ';' to open file finder (like your :Files)
map("n", ";", "<cmd>Telescope find_files<cr>", { silent = true })
-- <F6> toggle spell like before
map("n", "<F6>", "<cmd>setlocal spell!<cr>", { silent = true })
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { silent = true })

-- Optional: quick Hop word jump (Leader by default is '\\' in bare nvim)
map("n", "<leader><leader>w", "<cmd>HopWord<cr>", { silent = true })

-- Extra Hop bindings
map("n", "<leader><leader>f", "<cmd>HopChar1<cr>", { silent = true }) -- jump to a character
map("n", "<leader><leader>l", "<cmd>HopLine<cr>",  { silent = true }) -- jump to a line

-- Gitsigns bindings
map("n", "]c", function() require("gitsigns").next_hunk() end, { silent = true })
map("n", "[c", function() require("gitsigns").prev_hunk() end, { silent = true })
map("n", "<leader>hs", function() require("gitsigns").stage_hunk() end, { silent = true })
map("n", "<leader>hr", function() require("gitsigns").reset_hunk() end, { silent = true })
map("n", "<leader>hp", function() require("gitsigns").preview_hunk() end, { silent = true })
map("n", "<leader>hb", function() require("gitsigns").blame_line() end, { silent = true })
