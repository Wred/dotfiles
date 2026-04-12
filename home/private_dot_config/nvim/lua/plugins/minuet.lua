return {
	{
		"milanglacier/minuet-ai.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			request_timeout = 10,
			n_completions = 1,
			provider = "openai_compatible",
			provider_options = {
				openai_compatible = {
					api_key = "TERM",
					end_point = "http://localhost:11434/v1/chat/completions",
					model = "gemma4:e4b",
					name = "Ollama",
					stream = true,
					optional = {
						max_tokens = 512,
					},
				},
			},
			virtualtext = {
				auto_trigger_ft = {},
				keymap = {
					accept = "<A-a>",
					accept_line = "<A-l>",
					prev = "<A-[>",
					next = "<A-]>",
					dismiss = "<A-e>",
				},
			},
		},
	},
}
