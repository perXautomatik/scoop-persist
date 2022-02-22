local options = {
  backup = false, -- creates a backup file
  -- clipboard = "unnamedplus", -- allows neovim to access the system clipboard
  cmdheight = 1, -- more space in the neovim command line for displaying messages
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  -- conceallevel = 0,                        -- so that `` is visible in markdown files
  conceallevel = 2, -- conceal links in vimwiki
  fileencoding = "utf-8", -- the encoding written to a file
  fileformat = "unix",
  fileformats = "unix,dos",
  -- shellslash = true, -- breaks neo-tree and lir and maybe more
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  mouse = "a", -- allow the mouse to be used in neovim
  pumheight = 10, -- pop up menu height
  showmode = false, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 1, -- always show tabs
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go to the right of current window
  swapfile = false, -- creates a swapfile
  termguicolors = true, -- set term gui colors (most terminals support this)
  timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true, -- enable persistent undo
  updatetime = 300, -- faster completion (4000ms default)
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true, -- convert tabs to spaces
  shiftwidth = 2, -- the number of spaces inserted for each indentation
  tabstop = 2, -- insert 2 spaces for a tab
  cursorline = true, -- highlight the current line
  number = true, -- set numbered lines
  relativenumber = false, -- set relative numbered lines
  numberwidth = 4, -- set number column width to 2 {default 4}
  signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
  wrap = false, -- display lines as one long line
  scrolloff = 5, -- is one of my fav
  sidescrolloff = 10,
  foldlevelstart = 99,
  sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal",
  guifont = "JetbrainsMono Nerd Font:h16", -- the font used in graphical neovim applications
}

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- vim.cmd([[set formatoptions-=cro]]) -- TODO: this doesn't seem to work
vim.cmd([[
  if exists("g:nvy")
    cd $home
  endif
  set path+=**  "find files recursively
  set whichwrap+=<,>,[,],h,l
  " set iskeyword+=-
  set sessionoptions+=globals "persist bufferline buffers order(doesn't work)
  set concealcursor=nc
  hi Underlined guisp=#7aa2f7 " change vimwiki link color
  set grepprg=rg\ --vimgrep\ --smart-case " Replacing grep with rg
  set grepformat=%f:%l:%c:%m
]])

-- prettier folding
function _G.MyFoldText()
  return vim.fn.getline(vim.v.foldstart) .. " ... " .. vim.fn.getline(vim.v.foldend):gsub("^%s*", "")
end
vim.opt.foldtext = "v:lua.MyFoldText()"
vim.opt.fillchars:append({ fold = " " })

vim.g.python3_host_prog = "python3"

-- disable builtin plugins
vim.g.loaded_gzip = false
vim.g.loaded_tar = false
vim.g.loaded_tarPlugin = false
vim.g.zipPlugin = false
vim.g.loaded_zipPlugin = false
vim.g.loaded_2html_plugin = false
vim.g.loaded_remote_plugins = false