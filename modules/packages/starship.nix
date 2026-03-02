{
  programs.starship = {
    enable = true;
    settings = {
      # Move jj module right after directory; git-replacement custom modules stay in git position
      format = "$username$hostname$localip$shlvl$singularity$kubernetes$directory\${custom.jj}$vcsh$fossil_branch$fossil_metrics\${custom.git_branch}\${custom.git_commit}\${custom.git_state}\${custom.git_metrics}\${custom.git_status}$hg_branch$hg_state$pijul_channel$docker_context$package$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$fortran$gleam$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$typst$vlang$vagrant$zig$buf$nix_shell$conda$meson$spack$memory_usage$aws$gcloud$openstack$azure$nats$direnv$env_var$mise$crystal$sudo$cmd_duration$line_break$jobs$battery$time$status$os$container$netns$shell$character";

      status = {
        disabled = false;
      };

      # jj custom module
      custom.jj = {
        description = "The current jj status";
        when = "jj --ignore-working-copy root";
        symbol = "🔖 ";
        command = ''
          set bookmark_label (jj log --revisions @ --no-graph --ignore-working-copy --color never --limit 1 --template 'separate(" ", local_bookmarks)')
          if test -z "$bookmark_label"
            set ancestor (jj log --revisions 'latest(::@- & bookmarks())' --no-graph --ignore-working-copy --color never --limit 1 --template 'separate(" ", local_bookmarks)' 2>/dev/null)
            if test -n "$ancestor"
              set bookmark_label "⤷ $ancestor"
            end
          end
          set jj_output (jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
            separate(" ",
              change_id.shortest(4),
              "|",
              concat(
                if(conflict, "💥"),
                if(divergent, "🚧"),
                if(hidden, "👻"),
                if(immutable, "🔒"),
              ),
              raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
              raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                truncate_end(29, description.first_line(), "…"),
                "(no description set)",
              ) ++ raw_escape_sequence("\x1b[0m"),
            )
          ')
          if test -n "$bookmark_label"
            printf "%s %s" "$bookmark_label" "$jj_output"
          else
            printf "%s" "$jj_output"
          end
        '';
      };

      # Disable native git modules (replaced by custom ones below that only show outside jj repos)
      git_branch.disabled = true;
      git_commit.disabled = true;
      git_metrics.disabled = true;
      git_status.disabled = true;

      # Show git modules only when NOT in a jj repo
      custom.git_branch = {
        when = "! jj --ignore-working-copy root";
        command = "starship module git_branch";
        description = "Only show git_branch if we're not in a jj repo";
        style = "";
      };

      custom.git_commit = {
        when = "! jj --ignore-working-copy root";
        command = "starship module git_commit";
        description = "Only show git_commit if we're not in a jj repo";
        style = "";
      };

      custom.git_metrics = {
        when = "! jj --ignore-working-copy root";
        command = "starship module git_metrics";
        description = "Only show git_metrics if we're not in a jj repo";
        style = "";
      };

      custom.git_status = {
        when = "! jj --ignore-working-copy root";
        command = "starship module git_status";
        description = "Only show git_status if we're not in a jj repo";
        style = "";
      };
    };
  };
}
