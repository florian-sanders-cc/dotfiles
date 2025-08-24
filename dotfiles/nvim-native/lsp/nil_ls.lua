return {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
  settings = {
    ["nil"] = {
      maxMemoryMB =  8192,
      flake = {
        autoEvalInputs = true,
      }
    }
  }
}
