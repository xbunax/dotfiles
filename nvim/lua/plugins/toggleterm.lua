return { 
    'akinsho/toggleterm.nvim', version = "*", config = true, 
    config = function()
    require("toggleterm").setup {
  open_mapping = [[<c-\>]],
      }
end
}

