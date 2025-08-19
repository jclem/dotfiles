return {
	{
		desc = "Effect.gen",
		prefix = "gen",
		body = {
			"Effect.gen(function*() {",
			"\t$0",
			"})",
		},
	},
	{
		desc = "export named function",
		prefix = "ef",
		body = {
			"export function ${1:member}(${2:arguments}) {",
			"\t$0",
			"}",
		},
	},
}
