return {
	{
		desc = "Banner comment",
		prefix = "banner",
		body = {
			"/* ======================================================================",
			"",
			"\t$0",
			"",
			"====================================================================== */",
		},
	},
	{
		desc = "Effect.Service",
		prefix = "service",
		body = {
			"class $1 extends Effect.Service<$1>()(",
			"\t\"$1\",",
			"\t{",
			"\t\taccessors: true,",
			"",
			"\t\teffect: Effect.gen(function*() {",
			"\t\t\t$0",
			"",
			"\t\t\treturn {",
			"\t\t\t}",
			"\t\t}),",
			"}) {}",
		},
	},
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
