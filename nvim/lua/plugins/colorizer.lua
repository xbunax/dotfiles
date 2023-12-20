return {
    'norcalli/nvim-colorizer.lua',
    config = function()
        require 'colorizer'.setup {
            'css',
            'javascript',
            html = {
                mode = 'foreground',
            }
        }
    end
}
