-- ============================
--       General Settings
-- ============================

vim.opt.number = true                   -- Show line numbers
vim.opt.ignorecase = true               -- Ignore case in searches
vim.opt.smartcase = true                -- Case-sensitive if search contains uppercase
vim.opt.incsearch = true                -- Show matches as you type
vim.opt.hlsearch = true                 -- Highlight matches
vim.opt.autoindent = true                -- Copy indentation from previous line
vim.opt.smartindent = true               -- Smart auto-indentation
vim.opt.showcmd = true                   -- Show commands as you type them
vim.opt.ruler = true                     -- Show cursor position in status bar
vim.opt.cursorline = true                -- Highlight the current line
vim.opt.scrolloff = 5                    -- Keep 5 lines above and below cursor
vim.opt.sidescrolloff = 8                -- Keep some padding at the sides
vim.opt.lazyredraw = true                -- Don't redraw screen while executing macros
vim.opt.wrap = false                     -- Don't wrap long lines
vim.opt.undofile = true                  -- Enable persistent undo
vim.opt.undodir = os.getenv("HOME") .. "/.vim/nvim_undo"
vim.opt.foldlevel = 99                    -- Open all folds by default
vim.opt.encoding = "utf-8"               -- Set encoding to UTF-8

-- Tab inserts 4 spaces
vim.opt.expandtab = true                -- Use spaces instead of tabs
vim.opt.tabstop = 4                      -- Number of spaces per tab
vim.opt.shiftwidth = 4                   -- Number of spaces for auto-indent
vim.opt.softtabstop = 4                  -- Soft tab stops for smoother indenting
-- Shift+Tab removes 4 spaces
vim.api.nvim_set_keymap("i", "<S-CR>", "<C-o>o", { noremap = true, silent = true })
vim.cmd("syntax enable")                 -- Enable syntax highlighting

-- Enable full 24-bit color support
vim.opt.termguicolors = true
-- 
--vim.cmd.colorscheme("darcula-dark")

vim.opt.conceallevel = 0  -- Always show concealed text (e.g., double quotes in JSON)
-- ============================
--       Clipboard Configs
-- ============================
-- Use system clipboard for copy/paste
vim.opt.clipboard = "unnamedplus"

-- Map `yy` and `y` to copy to system clipboard
vim.api.nvim_set_keymap("n", "yy", '"+yy', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "y", '"+y', { noremap = true, silent = true })

-- -- Enable OSC 52 clipboard support
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = function(lines, _) require("vim.ui.clipboard.osc52").copy("+")(lines) end,
--     ["*"] = function(lines, _) require("vim.ui.clipboard.osc52").copy("*")(lines) end,
--   },
--   paste = {
--     ["+"] = function() return require("vim.ui.clipboard.osc52").paste("+")() end,
--     ["*"] = function() return require("vim.ui.clipboard.osc52").paste("*")() end,
--   },
-- }
--
-- Enable OSC 52 clipboard support safely
local status, osc52 = pcall(require, "vim.ui.clipboard.osc52")
if status then
    vim.g.clipboard = {
        name = "OSC 52",
        copy = {
            ["+"] = osc52.copy("+"),
            ["*"] = osc52.copy("*"),
        },
        paste = {
            ["+"] = osc52.paste("+"),
            ["*"] = osc52.paste("*"),
        },
    }
else
    print("Warning: OSC 52 clipboard support not available.")
end
-- ============================
--       Key Mappings
-- ============================

vim.keymap.set("n", "<Space>", ":noh<CR>", { silent = true })  -- Space clears search highlights
vim.keymap.set("n", "<C-p>", ":w<CR>:!chmod +x %; clear; python3 %<CR>", { noremap = true }) -- Run Python Script
vim.keymap.set("n", "<C-b>", ":w<CR>:!chmod +x %; clear; bash %<CR>", { noremap = true })    -- Run Bash Script
vim.keymap.set("n", "<F3>", ":if &number == 1 | set nonumber norelativenumber | else | set number | endif<CR>", { noremap = true })
vim.keymap.set("n", "<F4>", ":IndentLinesToggle<CR>", { noremap = true }) -- Toggle IndentLines
vim.keymap.set("n", "<F5>", ":lua ToggleCommentAndMove()<CR>", { noremap = true, silent = true }) -- Toggle comments
vim.keymap.set("n", "<F6>", ":lua ToggleMouse()<CR>", { noremap = true }) -- Toggle Mouse Support
vim.keymap.set("n", "<F10>", ":lua SudoSaveAndExit()<CR>", { noremap = true }) -- Save Read-Only File

-- ============================
--       Functions
-- ============================

-- Toggle mouse support
function ToggleMouse()
    if vim.o.mouse == "a" then
        vim.o.mouse = ""
        print("Mouse disabled")
    else
        vim.o.mouse = "a"
        print("Mouse enabled")
    end
end

-- Save and exit a read-only file
function SudoSaveAndExit()
    local tmpfile = vim.fn.tempname()
    vim.cmd("write! " .. tmpfile)
    vim.cmd("silent !mv " .. tmpfile .. " " .. vim.fn.expand("%"))
    vim.cmd("edit!")
    print("File saved successfully! Exiting Neovim...")
    vim.cmd("qall!")  -- Exit Neovim after saving
end

function ToggleCommentAndMove()
    local comment_leader = vim.b.comment_leader or "# " -- Default to `# ` for unknown filetypes
    local line = vim.api.nvim_get_current_line()

    -- Check if line is already commented
    local pattern = "^%s*" .. vim.pesc(comment_leader) -- Match optional spaces + comment leader
    if string.match(line, pattern) then
        -- Uncomment the line
        local uncommented_line = line:gsub(pattern, "", 1)
        vim.api.nvim_set_current_line(uncommented_line)
    else
        -- Comment the line
        vim.api.nvim_set_current_line(comment_leader .. line)
    end

    -- Move cursor to the next line
    vim.cmd("normal! j")
    vim.cmd("nohlsearch")  -- Remove search highlighting
end

-- ============================
--       Auto Commands
-- ============================

-- Remember last cursor position when reopening a file
vim.cmd([[
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
]])

-- Enable file type detection and plugin support
vim.cmd("filetype plugin on")

-- Define comment leaders based on file type
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "java", "scala" },
    command = "let b:comment_leader = '// '"
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sh", "ruby", "python", "bash" },
    command = "let b:comment_leader = '# '"
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "nginx",
    command = "let b:comment_leader = '# '"
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "vim",
    command = "let b:comment_leader = '\" '"
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.conf",
    command = "set filetype=conf"
})

-- ============================
--       Plugins (Lazy.nvim)
-- ============================


-- Ensure vim-plug is installed
local plug_path = vim.fn.stdpath("data") .. "/site/autoload/plug.vim"
if vim.fn.empty(vim.fn.glob(plug_path)) > 0 then
    vim.fn.system({
        "curl", "-fLo", plug_path, "--create-dirs",
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    })
end

-- -- Start Plugin Setup
-- vim.cmd [[
-- call plug#begin('~/.vim/plugged')
-- 
-- Plug 'vim-airline/vim-airline'
-- Plug 'Yggdroot/indentLine'
-- Plug 'elzr/vim-json'
-- Plug 'stephpy/vim-yaml'
-- Plug 'jiangmiao/auto-pairs'
-- Plug 'neoclide/coc.nvim', {'branch': 'release'}
-- Plug 'neovim/nvim-lspconfig'
-- 
-- call plug#end()
-- ]]

-- Set leader key (optional)
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  -- Example plugins:
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "xiantang/darcula-dark.nvim" },
  { "vim-airline/vim-airline" },
  { "Yggdroot/indentLine" },
  { "elzr/vim-json" },
  { "stephpy/vim-yaml" },
  { "jiangmiao/auto-pairs" },
  { "neovim/nvim-lspconfig" },
  { "neoclide/coc.nvim", branch = "release" } -- Corrected syntax
})

--       LSP Configuration
-- ============================

-- require'lspconfig'.bashls.setup{}

-- ============================
--       Completion Key Bindings
-- ============================

vim.api.nvim_set_keymap("i", "<Tab>", "pumvisible() ? '<C-n>' : '<Tab>'", { noremap = true, expr = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", "pumvisible() ? '<C-p>' : '<S-Tab>'", { noremap = true, expr = true })
vim.api.nvim_set_keymap("i", "<CR>", "pumvisible() ? '<C-y>' : '<CR>'", { noremap = true, expr = true })

vim.api.nvim_set_keymap("n", "K", ":call CocActionAsync('doHover')<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
vim.api.nvim_set_keymap("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })
vim.api.nvim_set_keymap("n", "gd", "<Plug>(coc-definition)", { silent = true })
vim.api.nvim_set_keymap("n", "gr", "<Plug>(coc-rename)", { silent = true })


vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.python3_host_prog = os.getenv("HOME") .. "/.venvs/neovim/bin/python"




-- Outdent (Shift+Comma) in normal mode
vim.keymap.set("n", "<lt>", "<lt><lt>", { silent = true, desc = "Outdent" })

-- Indent (Shift+Period) in normal mode
vim.keymap.set("n", ">", ">>", { silent = true, desc = "Indent" })

-- Outdent (Shift+Comma) in visual mode and reselect the selection
vim.keymap.set("v", "<lt>", "<lt>gv", { silent = true, desc = "Outdent and reselect" })

-- Indent (Shift+Period) in visual mode and reselect the selection
vim.keymap.set("v", ">", ">gv", { silent = true, desc = "Indent and reselect" })



-- Delete a single line (`dd`) without copying it to the clipboard
vim.api.nvim_set_keymap("n", "dd", '"_dd', { noremap = true, silent = true })

-- Delete selected text (`d`) in visual mode without copying it
vim.api.nvim_set_keymap("v", "d", '"_d', { noremap = true, silent = true })

