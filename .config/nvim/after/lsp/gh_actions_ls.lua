-- Use GitHub's official Actions language server executable with nvim-lspconfig's
-- workflow-only root detection and file-reading handler.
-- https://github.com/actions/languageservices/tree/main/languageserver
return {
    cmd = { "actions-languageserver", "--stdio" },
}
