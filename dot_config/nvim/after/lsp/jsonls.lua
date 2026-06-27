-- Add the SchemaStore catalog to the default jsonls configuration.
-- https://github.com/b0o/schemastore.nvim
return {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
}
