return {
    'chomosuke/typst-preview.nvim',
    -- lazy = false, -- or ft = 'typst'
    ft = 'typst',
    version = '0.1.*',
    build = function() require 'typst-preview'.update() end,
    opts = {
        debug = false,
        get_root = function(bufnr_of_typst_buffer)
            return vim.fn.fnamemodify(vim.fn.expand('%:p'), ':h')
        end,
    },
    config = function()
        -- require 'typst-preview'.sync_with_cursor()
        require 'typst-preview'.set_follow_cursor(true)
    end
}
