--remap vertical split
vim.cmd([[let g:nremap = {"gO": "o"}]])

function GitHistoryForVisualLines()
	local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, '<'))
	local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, '>'))
	vim.api.nvim_command(string.format("vertical Git log --oneline --no-patch -L%d,%d:%%", start_row, end_row))
	vim.cmd("wincmd o")
        vim.api.nvim_buf_set_option(0, 'bufhidden', "hide")
        vim.api.nvim_buf_set_option(0, 'buflisted', true)
end

local default_options = {noremap = true, silent = true}
vim.api.nvim_set_keymap("v", "x", ":lua GitHistoryForVisualLines()<CR>", default_options)
