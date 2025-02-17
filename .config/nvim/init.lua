-- ============================
--       General Settings
-- ============================

vim.opt.number = true                   -- Show line numbers
vim.opt.termguicolors = true            -- Use full 24-bit colors
vim.opt.ignorecase = true               -- Ignore case in searches
vim.opt.smartcase = true                -- Case-sensitive if search contains uppercase
vim.opt.incsearch = true                -- Show matches as you type
vim.opt.hlsearch = true                 -- Highlight matches
vim.opt.expandtab = true                -- Use spaces instead of tabs
vim.opt.tabstop = 4                      -- Number of spaces per tab
vim.opt.shiftwidth = 4                   -- Number of spaces for auto-indent
vim.opt.softtabstop = 4                  -- Soft tab stops for smoother indenting
vim.opt.autoindent = true                -- Copy indentation from previous line
vim.opt.smartindent = true               -- Smart auto-indentation
vim.opt.clipboard = "unnamedplus"        -- Use system clipboard
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

vim.cmd("syntax enable")                 -- Enable syntax highlighting

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
vim.keymap.set("n", "<F10>", ":lua SudoSave()<CR>", { noremap = true }) -- Save Read-Only File

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

-- Save a read-only file
function SudoSave()
    local tmpfile = vim.fn.tempname()
    vim.cmd("write! " .. tmpfile)
    vim.cmd("silent !mv " .. tmpfile .. " " .. vim.fn.expand("%"))
    vim.cmd("edit!")
    print("File saved successfully!")
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

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "vim-airline/vim-airline" },
    { "Yggdroot/indentLine" },
    { "elzr/vim-json" },
    { "stephpy/vim-yaml" },
    { "jiangmiao/auto-pairs" },
    { "chr4/nginx.vim" },
    { "neoclide/coc.nvim", branch = "release" },
    { "neovim/nvim-lspconfig" }
})

-- ============================
--       LSP Configuration
-- ============================

require'lspconfig'.bashls.setup{}

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
