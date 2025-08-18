return {
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
