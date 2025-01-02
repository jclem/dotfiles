return {
	"echasnovski/mini.pairs",
	version = "*",
	config = function(_, opts)
		require("mini.pairs").setup(opts or {})
	end
}
