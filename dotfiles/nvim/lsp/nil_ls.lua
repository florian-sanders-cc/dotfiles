return {
  cmd = { "nil" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    ["nil"] = {
      nix = {
        maxMemoryMB = 8192,
        flake = {
          autoEvalInputs = true,
          autoArchive = true,
          nixpkgsInputName = "nixpkgs",
        },
      },
    },
  },
}
