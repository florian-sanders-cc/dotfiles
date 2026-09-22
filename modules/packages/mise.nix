{ ... }:

{
  programs.mise = {
    enable = true;

    # ~/.config/mise/config.toml is fully declarative (read-only symlink into
    # the store). `mise use --global` will not work; add tools here instead.
    globalConfig.settings = {
      # mise's compile-from-source path is broken for some tools (pnpm), so
      # always prefer precompiled release binaries.
      all_compile = false;
    };
  };
}
