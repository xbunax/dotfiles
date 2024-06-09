return {
    
    'norcalli/nvim-colorizer.lua',
    config = function()
        require 'colorizer'.setup {
            'css',
            'javascript',
            "sh",
            html = {
                mode = 'foreground',
            },
            -- css = { rgb_fn = true, },    -- Enable parsing rgb(...) functions in css.
            -- html = { names = false, }    -- Disable parsing "names" like Blue or Gray
            DEFAULT_OPTIONS = {
                -- RGB      = true,         -- #RGB hex codes
                -- RRGGBB   = true,         -- #RRGGBB hex codes
                -- names    = true,         -- "Name" codes like Blue
                -- RRGGBBAA = true,         -- #RRGGBBAA hex codes
                -- rgb_fn   = true,        -- CSS rgb() and rgba() functions
                -- hsl_fn   = true,        -- CSS hsl() and hsla() functions
                -- css      = true,         -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                -- css_fn   = true,        -- Enable all CSS *functions*: rgb_fn, hsl_fn
                -- -- Available modes: foreground, background
                -- mode     = 'background', -- Set the display mode.
            }
        }
    end
}
