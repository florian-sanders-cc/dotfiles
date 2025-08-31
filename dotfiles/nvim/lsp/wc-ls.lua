local function find_typescript_lib()
  local handle =
    io.popen("nix-store --query --requisites $(which tsc) 2>/dev/null | grep -E 'typescript-[0-9]+' | head -1")
  if handle then
    local result = handle:read("*a")
    handle:close()
    if result and result ~= "" then
      local ts_store_path = result:gsub("%s+", "")
      return ts_store_path .. "/lib/node_modules/typescript/lib"
    end
  end
end

return {
  cmd = { "wc-language-server", "--stdio" },
  filetypes = { "html", "javascript", "typescript" },
  init_options = {
    typescript = {
      tsdk = find_typescript_lib(),
    },
  },
  root_markers = {
    "package.json",
    "wc.config.js",
    ".git",
  },
}
