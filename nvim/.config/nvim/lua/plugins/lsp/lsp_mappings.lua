local PluginUtil = require("utils.plugins")

local M = {}

M.on_attach = function(client, bufnr)
    if Disable_Lsp_Server_Formatting then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end

    if PluginUtil.has("nvim-naviac") then
        if client.server_capabilities.documentSymbolProvider then
            local naviac = require("nvim-navic")
            naviac.attach(client, bufnr) -- attaching naviac.
        end
    end

    -- MAPPING FUNCTIONS
    local nmap = function(keys, func, desc)
        if desc then
            desc = desc .. " (lsp)"
        end
        vim.keymap.set("n", keys, func, {
            buffer = bufnr,
            desc = desc,
            noremap = true,
        })
    end
    local nmap_saga = function(keys, func, desc)
        if desc then
            desc = desc .. " (lsp saga)"
        end
        vim.keymap.set("n", keys, func, {
            buffer = bufnr,
            desc = desc,
            noremap = true,
        })
    end

    vim.keymap.set("n", "<leader>ll", "<cmd>LspRestart<CR>", {
        desc = "Lsp: restart",
    })
    -- KEY MAPPINGS
    if PluginUtil.has("inc-rename.nvim") then
        vim.keymap.set("n", "<leader>rn", function()
            return ":IncRename " .. vim.fn.expand("<cword>")
        end, { desc = "[R]e[n]ame (inc_rename)", expr = true })
    else
        if PluginUtil.has("lspsaga.nvim") then
            nmap_saga("<leader>rn", "<cmd>Lspsaga rename<cr>", "[R]e[n]ame -> c-k:quit")
        else
            nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        end
    end

    if PluginUtil.has("lspsaga.nvim") then
        nmap_saga("<leader>A", "<cmd>Lspsaga code_action<cr>", "Code [A]ctions")

        nmap_saga("gd", "<cmd>Lspsaga goto_definition<cr>", "[g]oto [d]efinition")
        nmap_saga("gh", "<cmd>Lspsaga peek_definition<cr>", "[g]et definition [h]ere")

        nmap_saga("K", "<cmd>Lspsaga hover_doc<cr>", "Hover Doc")

        nmap_saga("<leader>p", "<cmd>Lspsaga show_line_diagnostics<cr>", "Show Diagnostics/[p]roblems")
        nmap_saga("<leader>P", "<cmd>Lspsaga show_cursor_diagnostics<cr>", "Show (curr loc) Diagnostic/[P]roblem")

        nmap_saga("[d", "<cmd>Lspsaga diagnostic_jump_next<cr>", "Goto next [d]iagnostic")
        nmap_saga("]d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", "Goto prev [d]iagnostic")
    else
        nmap("<leader>A", vim.lsp.buf.code_action, "Code [A]ctions")

        nmap("gd", vim.lsp.buf.definition, "[g]oto [d]efinition")

        nmap("K", vim.lsp.buf.hover, "Hover Doc")

        nmap("<leader>p", function()
            vim.diagnostic.open_float()
        end, {
            desc = "Show Diagnostics/[p]roblems",
        })

        nmap("[d", function()
            vim.diagnostic.goto_next()
        end, {
            desc = "Goto next [d]iagnostic",
        })
        nmap("]d", function()
            vim.diagnostic.goto_prev()
        end, {
            desc = "Goto prev [d]iagnostic",
        })
    end
    -- nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation") -- INFO: not working/know more
    -- nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition") -- INFO: not working/know more
    nmap("<leader>K", vim.lsp.buf.signature_help, "Hover Signature Help")

    --nmap("gs", vim.lsp.buf.declaration, "[G]oto [D]eclaration")-- INFO: not working/know more
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace: [A]dd this root")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace: [R]emove this root")
    nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace: [L]ist Folders")

    -- SYMBOLS USING TELESCOPE
    nmap("<leader>sr", require("telescope.builtin").lsp_references, "[s]earch [r]eferences -> cur @parameter")
    nmap("<leader>ss", require("telescope.builtin").lsp_document_symbols, "[s]earch [s]ymbols -> buffer") --
    nmap("<leader>sw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[s]earch [S]ymbols -> workspace") --

    -- condition capabilities
    if client.name == "ruff_lsp" then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
    end
end

return M
