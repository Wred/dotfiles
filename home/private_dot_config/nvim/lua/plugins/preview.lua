return {
	{
		'brianhuster/live-preview.nvim',
		lazy = false,
		dependencies = {
			'nvim-telescope/telescope.nvim',
		},
		keys = {
			{
				'<leader>pp',
				function()
					vim.cmd('LivePreview close')
					vim.cmd('LivePreview start')
				end,
				desc = 'Live Preview Start',
			},
			{
				'<leader>pc',
				'<cmd>LivePreview close<CR>',
				desc = 'Live Preview Close',
			},
		},

	},
}
