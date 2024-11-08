require("opts_and_keys")

-- NOTE: register the extra lze handlers because we want to use them.
require("lze").register_handlers(require("lze.x"))

require("plugins")

-- I dont need to explain why this is called lsp right?
require("LSPs")

-- NOTE: we even ask nixCats if we included our debug stuff in this setup! (we didnt)
-- But we have a good base setup here as an example anyway!
if nixCats("debug") then require("debug.init") end
-- NOTE: we included these though! Or, at least, the category is enabled.
-- these contain nvim-lint and conform setups.
if nixCats("lint") then require("lint") end
if nixCats("format") then require("format") end
