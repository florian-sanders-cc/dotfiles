Ah — these are Zed's built-in keymaps (the `VS Code` base keymap option vs the Vim mode plugin). These ship inside the Zed app bundle, not in your project, so let me check whether they're reachable on disk.

My sub-agent (and I) lack shell access to read files outside the project — Zed's installed keymaps live in a read-only Nix store path I can't list. But Zed is open source, so let me fetch the upstream keymap files from GitHub and compare those. If your installed version differs, you can re-run the comparison against your local install, but upstream is the right baseline.

Found them. There's no `vscode.json` at the top level — Zed's non-default base keymaps (VSCode, JetBrains, etc.) live in the platform subdirectories. Let me see what's in `assets/keymaps/linux/` and macOS to find the right file since `vim.json` lives at top level. The system is Linux. Let me delegate the parsing to a sub-agent — these files are huge (57KB + 44KB) and I only need the conflict set.

Now I have `vim.json`. Let me fetch the Linux VSCode base keymap — it's small (2.2KB), and pairing it with the vim.json I already have will let me find conflicts directly.

Key finding: the `linux/vscode.json` is just a thin **overlay** on top of Zed's default keymap (only 8 short blocks). So the effective "VSCode base keymap" in Zed = `default-linux.json` (57KB) + the small `linux/vscode.json` overlay. To list real conflicts with vim mode, I need to compare that merged set against `vim.json`. This is a big parse-and-compare task — I'll delegate it.

Here are the conflicts between Zed's **VSCode base keymap** and the built-in **Vim mode**. The VSCode base is actually `default-linux.json` + a small `linux/vscode.json` overlay; vim mode layers `vim.json` on top, and the more specific vim context wins.

## Table A — Normal-mode conflicts

| Key | VSCode action | Vim action | Vim context |
|---|---|---|---|
| backspace | `editor::Backspace` | `vim::WrappingLeft` | `VimControl && !menu` |
| ctrl-a | `editor::SelectAll` | `vim::Increment` | `vim_mode == normal` |
| ctrl-b | `workspace::ToggleLeftDock` | `vim::PageUp` | `VimControl && !menu` |
| ctrl-d | `editor::SelectNext` | `vim::ScrollDown` | `VimControl && !menu` |
| ctrl-f | `buffer_search::Deploy` | `vim::PageDown` | `VimControl && !menu` |
| ctrl-g | `go_to_line::Toggle` | `vim::ShowLocation` | `VimControl && !menu` |
| ctrl-i | `assistant::InlineAssist` | `pane::GoForward` | `VimControl && !menu` |
| ctrl-j | `workspace::ToggleBottomDock` | `vim::Down` | `VimControl && !menu` |
| ctrl-m | `editor::MoveToEnclosingBracket` | `vim::NextLineStart` | `VimControl && !menu` |
| ctrl-o | `workspace::OpenFiles` | `pane::GoBack` | `VimControl && !menu` |
| ctrl-q | `zed::Quit` | `vim::ToggleVisualBlock` | `VimControl && !menu` |
| ctrl-r | `projects::OpenRecent` | `vim::Redo` | `vim_mode == normal` |
| ctrl-t | `project_symbols::Toggle` | `pane::GoToOlderTag` | `VimControl && !menu` |
| ctrl-u | `editor::UndoSelection` | `vim::ScrollUp` | `VimControl && !menu` |
| ctrl-v | `editor::Paste` | `vim::ToggleVisualBlock` | `VimControl && !menu` |
| ctrl-y | `editor::Redo` | `vim::LineUp` | `VimControl && !menu` |
| ctrl-[ | `editor::Outdent` | `editor::Cancel` | `vim_mode == normal` |
| ctrl-x | `editor::Cut` | `vim::Decrement` | `vim_mode == normal` |
| delete | `editor::Delete` | `vim::DeleteRight` | `vim_mode == normal` |
| down | `editor::MoveDown` | `vim::Down` | `VimControl && !menu` |
| end | `editor::MoveToEndOfLine` | `vim::EndOfLine` | `VimControl && !menu` |
| enter | `editor::Newline` | `vim::NextLineStart` | `VimControl && !menu` |
| home | `editor::MoveToBeginningOfLine` | `vim::StartOfLine` | `VimControl && !menu` |
| left | `editor::MoveLeft` | `vim::Left` | `VimControl && !menu` |
| pagedown | `editor::MovePageDown` | `vim::PageDown` | `VimControl && !menu` |
| pageup | `editor::MovePageUp` | `vim::PageUp` | `VimControl && !menu` |
| right | `editor::MoveRight` | `vim::Right` | `VimControl && !menu` |
| shift-tab | `editor::Backtab` | `vim::Tab` | `VimControl && !menu` |
| tab | `editor::Tab` | `vim::Tab` | `VimControl && !menu` |
| up | `editor::MoveUp` | `vim::Up` | `VimControl && !menu` |

`escape`, `ctrl-pageup`, `ctrl-pagedown` map to the same action in both → not real conflicts.

## Table B — Insert-mode conflicts

| Key | VSCode action | Vim action | Vim context |
|---|---|---|---|
| ctrl-c | `editor::Copy` | `vim::NormalBefore` | `vim_mode == insert` |
| ctrl-d | `editor::SelectNext` | `vim::Outdent` | `vim_mode == insert` |
| ctrl-k | `ctrl-k` chord prefix | `vim::PushDigraph` | `vim_mode == insert` |
| ctrl-n | `workspace::NewFile` | `editor::ShowWordCompletions` | `vim_mode == insert && !…` |
| ctrl-o | `workspace::OpenFiles` | `vim::TemporaryNormal` | `vim_mode == insert` |
| ctrl-p | `file_finder::Toggle` | `editor::ShowWordCompletions` | `vim_mode == insert && !…` |
| ctrl-q | `zed::Quit` | `vim::PushLiteral` | `vim_mode == insert` |
| ctrl-r | `projects::OpenRecent` | `vim::PushRegister` | `vim_mode == insert` |
| ctrl-s | `workspace::Save` | `editor::ShowSignatureHelp` | `vim_mode == insert` |
| ctrl-t | `project_symbols::Toggle` | `vim::Indent` | `vim_mode == insert` |
| ctrl-u | `editor::UndoSelection` | `editor::DeleteToBeginningOfLine` | `vim_mode == insert` |
| ctrl-v | `editor::Paste` | `vim::PushLiteral` | `vim_mode == insert` |
| ctrl-w | `pane::CloseActiveItem` | `editor::DeleteToPreviousWordStart` | `vim_mode == insert` |
| ctrl-y | `editor::Redo` | `vim::InsertFromAbove` | `vim_mode == insert` |
| ctrl-[ | `editor::Outdent` | `vim::NormalBefore` | `vim_mode == insert` |
| escape | `editor::Cancel` | `vim::NormalBefore` | `vim_mode == insert` |

Note: in insert mode vim sets plain `ctrl-x` to `null` so its `ctrl-x ctrl-*` digraph/completion chords work — so `editor::Cut` on `ctrl-x` still works in insert mode (it's only in **normal** mode that `ctrl-x` becomes `vim::Decrement`).

## Table C — Visual-mode conflicts (those unique to visual, beyond Table A)

| Key | VSCode action | Vim action | Vim context |
|---|---|---|---|
| ctrl-[ | `editor::Outdent` | `vim::SwitchToNormalMode` | `vim_mode == visual` |
| ctrl-a | `editor::SelectAll` | `vim::Increment` | `vim_mode == visual` |
| ctrl-c | `editor::Copy` | `vim::SwitchToNormalMode` | `vim_mode == visual` |
| ctrl-x | `editor::Cut` | `vim::Decrement` | `vim_mode == visual` |
| delete | `editor::Delete` | `vim::VisualDelete` | `vim_mode == visual` |
| escape | `editor::Cancel` | `vim::SwitchToNormalMode` | `vim_mode == visual` |

## Most impactful conflicts (for a VSCode user's muscle memory)

- **`ctrl-v`** — paste becomes literal-char insert in insert mode, and visual-block select in normal/visual. Paste still works on `ctrl-shift-v` in insert mode (vim aliases it to `editor::Paste`).
- **`ctrl-c`** — copy becomes "exit to normal mode" (both visual and insert). Use the platform copy key instead.
- **`ctrl-x`** — cut becomes `vim::Decrement` in normal mode. (Cut still works in insert mode where vim nulls `ctrl-x`.)
- **`ctrl-a`** — select all becomes `vim::Increment` (increments the number under cursor).
- **`ctrl-d`** — "select next match / add cursor" becomes half-page scroll down in normal mode.
- **`ctrl-f`** — find becomes `vim::PageDown` in normal mode. Use vim's `/` instead, or be in insert mode when you press it.
- **`ctrl-s`** — save becomes `editor::ShowSignatureHelp` in insert mode (save still works in normal mode).
- **`ctrl-o`** — open file becomes jump-list back in normal mode; `vim::TemporaryNormal` in insert.
- **`ctrl-t`** — workspace symbol search becomes "go back from definition" (jump list).
- **`ctrl-b`** — toggle sidebar becomes `vim::PageUp` in normal mode.
- **`ctrl-j`** — toggle bottom panel becomes `vim::Down` in normal mode.
- **`ctrl-w`** — close tab/panel becomes delete-to-previous-word in insert mode, and a window/split command prefix (`ctrl-w h/j/k/l`, `ctrl-w v`, …) in normal mode.
- **`ctrl-u`** — undo-selection becomes half-page scroll (normal) or delete-to-start-of-line (insert).
- **`ctrl-y`** — redo becomes `vim::LineUp`; redo is moved to `ctrl-r`.
- **`ctrl-q`** — quit becomes visual-block select (normal) or literal-char insert (insert).
- **`ctrl-g`** — go-to-line becomes `vim::ShowLocation` (just shows cursor position).
- **`ctrl-m`** — move-to-enclosing-bracket becomes `vim::NextLineStart`.

A subtlety worth noting: in normal mode `enter` becomes "next line start" rather than inserting a newline, and `tab`/`shift-tab` become `vim::Tab` rather than editor indent/backtab — so arrow-and-tab users will mostly still navigate, but enter/tab don't do what a VSCode user expects while in normal mode.

### Caveats
- These reflect **upstream `main`** keymaps from `zed-industries/zed`. Your installed Zed version may differ slightly, but the structure of the VSCode overlay (thin delta on `default-linux.json`) and the vim keymap is stable across recent releases.
- I computed overlaps manually by fetching the three keymap JSON files; I did not have access to your installed copy. If you want a diff against the exact files on your machine instead, point me at their paths (or paste them) and I'll redo the comparison.
