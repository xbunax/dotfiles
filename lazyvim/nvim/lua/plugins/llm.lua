return {
  "huggingface/llm.nvim",
  opts = {
    model = "deepseek-r1:8b",
    backend = "ollama",
    url = "http://localhost:11434",
    request_body = {
      parameters = {
        max_new_tokens = 100000, -- the maximum numbers of tokens to generate, ignore the number of prompt token
        temperature = 0.2, -- the bigger, more creatively
        top_p = 0.95, -- the bigger, text generated is diverse
      },
    },
    tokens_to_clear = { "<|endoftext|>" },
    fim = {
      enabled = true,
      prefix = "<fim_prefix>",
      middle = "<fim_middle>",
      suffix = "<fim_suffix>",
    },
    accept_keymap = "<Tab>",
    dismiss_keymap = "<S-Tab>",
    lsp = {
      bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
    },
    context_window = 100000, -- max number of tokens for the context window
    tokenizer = nil,
    enable_suggestions_on_startup = true,
    enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
    disable_url_path_completion = false, -- cf Backend
    -- repository = "Bin12345/AutoCoder_S_6.7B",
  },
}
