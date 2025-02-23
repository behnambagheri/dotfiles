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
vim.opt.encoding = "utf-8"               -- Set encoding to UTF-8

vim.opt.expandtab = true                -- Use spaces instead of tabs
vim.opt.tabstop = 4                      -- Number of spaces per tab
vim.opt.shiftwidth = 4                   -- Number of spaces for auto-indent
vim.opt.softtabstop = 4                  -- Soft tab stops for smoother indenting

vim.cmd("syntax enable")                 -- Enable syntax highlighting

-- Enable folding
vim.opt.foldmethod = "indent"  -- Fold based on indentation
vim.opt.foldlevel = 99         -- Start with all folds open
vim.opt.foldenable = true      -- Enable folding by default

vim.opt.termguicolors = true -- Enable full 24-bit color support

-- vim.g.vim_json_conceal = 0  -- Show all quotes in JSON
-- ============================
--       Clipboard Configs
-- ============================

-- Use system clipboard for copy/paste
vim.opt.clipboard = "unnamedplus"

-- Map `yy` and `y` to copy to system clipboard
vim.api.nvim_set_keymap("n", "yy", '"+yy', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "y", '"+y', { noremap = true, silent = true })

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
-- Disable json concealing
vim.cmd("let g:vim_json_syntax_conceal = 0")
-- Define comment leaders based on file type
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "java", "scala" },
    command = "let b:comment_leader = '// '"
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sh", "ruby", "python", "bash", "nginx" },
    command = "let b:comment_leader = '# '"
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "vim",
    command = "let b:comment_leader = '-- '"
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    command = "let b:comment_leader = '-- '"
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.conf",
    command = "set filetype=conf"
})


-- ============================
--       Plugins (vim-plug)
-- ============================


-- Ensure vim-plug is installed
local plug_path = vim.fn.stdpath("data") .. "/site/autoload/plug.vim"
if vim.fn.empty(vim.fn.glob(plug_path)) > 0 then
    vim.fn.system({
        "curl", "-fLo", plug_path, "--create-dirs",
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    })
end

-- Start Plugin Setup
vim.cmd [[
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'Yggdroot/indentLine'
Plug 'elzr/vim-json'
Plug 'stephpy/vim-yaml'
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neovim/nvim-lspconfig'

call plug#end()
]]

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

