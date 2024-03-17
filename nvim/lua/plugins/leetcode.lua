return {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- required by telescope
        "MunifTanjim/nui.nvim",

        -- optional
        "nvim-treesitter/nvim-treesitter",
        "rcarriga/nvim-notify",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
    },
    config = function()
        require("leetcode").setup({
            lang = "python3",
            cn = {
                enabled = true,
                translator = true,
                translate_problems = true,
            },
            storage = {
                home = vim.fn.stdpath("data") .. "/leetcode",
                cache = vim.fn.stdpath("cache") .. "/leetcode",
            },
            logging = true,
            injector = {},
            cache = {
                update_interval = 60 * 60 * 24 * 7,
            },
            console = {
                open_on_runcode = true,
                dir = "row",
                size = {
                    width = "90%",
                    height = "75%",
                },
                result = {
                    size = "60%",
                },
                testcase = {
                    virt_text = true,
                    size = "40%",
                },
            },
            description = {
                position = "left",
                width = "40%",
                show_stats = true,
            },
            hooks = {
                LeetEnter = {},
                LeetQuestionNew = {},
            },
            keys = {
                toggle = { "q", "<Esc>" },
                confirm = { "<CR>" },
                reset_testcases = "r",
                use_testcase = "U",
                focus_testcases = "H",
                focus_result = "L",
            },
            image_support = true,
        })
    end
}
