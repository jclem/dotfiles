-- Add the SchemaStore catalog to YAML Language Server's default configuration.
-- https://github.com/b0o/SchemaStore.nvim
return {
    settings = {
        yaml = {
            schemaStore = {
                enable = false,
                url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
        },
    },
}
