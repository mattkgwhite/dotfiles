# Keyboard shortcuts

Reference for all active keybindings across Ghostty, tmux, and zsh.

---

## Ghostty

No custom keybinds are defined; these are all defaults. Since Ghostty starts tmux on launch, native split/tab commands go through tmux in practice, but Ghostty-level window management still works.

### Clipboard

| Key | Action |
|-----|--------|
| `Cmd+C` | Copy to clipboard |
| `Cmd+V` | Paste from clipboard |
| `Cmd+Shift+V` | Paste from selection |
| `Cmd+A` | Select all |

### Windows & tabs

| Key | Action |
|-----|--------|
| `Cmd+N` | New window |
| `Cmd+W` | Close surface (split/tab/window) |
| `Cmd+Alt+W` | Close tab |
| `Cmd+Shift+W` | Close window |
| `Cmd+T` | New tab |
| `Cmd+Shift+[` | Previous tab |
| `Cmd+Shift+]` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+Tab` | Next tab |
| `Cmd+1`–`Cmd+8` | Go to tab 1–8 |
| `Cmd+9` | Go to last tab |

### Splits (native Ghostty splits, not tmux)

| Key | Action |
|-----|--------|
| `Cmd+D` | New split right |
| `Cmd+Shift+D` | New split down |
| `Cmd+[` | Previous split |
| `Cmd+]` | Next split |
| `Cmd+Alt+↑/↓/←/→` | Go to split in direction |
| `Cmd+Ctrl+↑/↓/←/→` | Resize split |
| `Cmd+Ctrl+=` | Equalize splits |
| `Cmd+Shift+Enter` | Toggle split zoom |
| `Cmd+Enter` | Toggle fullscreen |
| `Cmd+Ctrl+F` | Toggle fullscreen (alternate) |

### Font & display

| Key | Action |
|-----|--------|
| `Cmd+=` / `Cmd++` | Increase font size |
| `Cmd+-` | Decrease font size |
| `Cmd+0` | Reset font size |
| `Cmd+K` | Clear screen |

### Search

| Key | Action |
|-----|--------|
| `Cmd+F` | Start search |
| `Cmd+G` | Next search result |
| `Cmd+Shift+G` | Previous search result |
| `Cmd+Shift+F` / `Escape` | End search |
| `Cmd+E` | Search selection |

### Scrollback

| Key | Action |
|-----|--------|
| `Cmd+Home` | Scroll to top |
| `Cmd+End` | Scroll to bottom |
| `Cmd+Page Up` | Scroll page up |
| `Cmd+Page Down` | Scroll page down |
| `Cmd+J` | Scroll to selection |
| `Cmd+↑` / `Cmd+Shift+↑` | Jump to previous prompt |
| `Cmd+↓` / `Cmd+Shift+↓` | Jump to next prompt |

### Screen capture

| Key | Action |
|-----|--------|
| `Cmd+Shift+J` | Write screen to file and paste |
| `Cmd+Ctrl+Shift+J` | Write screen to file and copy |
| `Cmd+Alt+Shift+J` | Write screen to file and open |

### Config

| Key | Action |
|-----|--------|
| `Cmd+,` | Open config |
| `Cmd+Shift+,` | Reload config |
| `Cmd+Shift+P` | Command palette |
| `Cmd+Alt+I` | Toggle inspector |

### Line editing (passthrough to shell)

| Key | Action |
|-----|--------|
| `Cmd+→` | Move to end of line (`^E`) |
| `Cmd+←` | Move to beginning of line (`^A`) |
| `Cmd+Backspace` | Delete to beginning of line (`^U`) |
| `Alt+→` | Forward word |
| `Alt+←` | Backward word |

---

## tmux

**Prefix: `Ctrl-a`**

Stock tmux bindings (`Ctrl-b`) are disabled. All bindings below require the prefix unless marked *(no prefix)*.

### Sessions

| Key | Action |
|-----|--------|
| `Ctrl-a Ctrl-c` | New session |
| `Ctrl-a Ctrl-f` | Find/switch session by name |
| `Ctrl-a Shift-Tab` | Switch to last session |
| `Ctrl-a s` | Interactive session chooser |
| `Ctrl-a $` | Rename session |
| `Ctrl-a d` | Detach |

### Windows

| Key | Action |
|-----|--------|
| `Ctrl-a c` | New window |
| `Ctrl-a Tab` | Last active window |
| `Ctrl-a Ctrl-h` | Previous window *(repeatable)* |
| `Ctrl-a Ctrl-l` | Next window *(repeatable)* |
| `Ctrl-a Ctrl-Shift-H` | Swap window left *(repeatable)* |
| `Ctrl-a Ctrl-Shift-L` | Swap window right *(repeatable)* |
| `Ctrl-a 0`–`9` | Go to window by number |
| `Ctrl-a ,` | Rename window |
| `Ctrl-a w` | Interactive window chooser |
| `Ctrl-a &` | Kill window |

### Panes

| Key | Action |
|-----|--------|
| `Ctrl-a -` | Split pane top/bottom |
| `Ctrl-a _` | Split pane left/right |
| `Ctrl-a h/j/k/l` | Select pane left/down/up/right |
| `Ctrl-a H/J/K/L` | Resize pane left/down/up/right by 2 *(repeatable)* |
| `Ctrl-a >` | Swap pane with next |
| `Ctrl-a <` | Swap pane with previous |
| `Ctrl-a {` | Swap pane with previous (stock) |
| `Ctrl-a }` | Swap pane with next (stock) |
| `Ctrl-a +` | Maximize/restore pane |
| `Ctrl-a z` | Toggle pane zoom |
| `Ctrl-a !` | Break pane into new window |
| `Ctrl-a q` | Display pane numbers |
| `Ctrl-a x` | Kill pane |
| `Ctrl-a Space` | Next layout |

### Copy mode (vi bindings)

| Key | Action |
|-----|--------|
| `Ctrl-a Enter` | Enter copy mode |
| `v` | Begin selection |
| `Ctrl-v` | Toggle rectangle selection |
| `y` | Copy selection and exit |
| `H` | Start of line |
| `L` | End of line |
| `Escape` | Cancel / exit copy mode |

### Paste buffers

| Key | Action |
|-----|--------|
| `Ctrl-a p` | Paste from top buffer |
| `Ctrl-a P` | Choose buffer to paste from |
| `Ctrl-a b` | List paste buffers |

### Utilities

| Key | Action |
|-----|--------|
| `Ctrl-a r` | Reload tmux config |
| `Ctrl-a e` | Open file in nvim in a split (prompts for filename) |
| `Ctrl-a /` | Open man page in a split (prompts for page name) |
| `Ctrl-a m` | Toggle mouse mode |
| `Ctrl-a F` | Launch fpp (file path picker) |
| `Ctrl-a t` | Show clock |
| `Ctrl-a :` | Command prompt |
| `Ctrl-a ?` | List all keybindings |
| `Ctrl-L` *(no prefix)* | Clear screen and scrollback history |

---

## zsh

### vi mode

zsh runs in vi mode (from `oh-my-zsh/vi-mode`). Press `Esc` to enter normal mode; `i` or `a` to return to insert.

#### Normal mode (vicmd)

| Key | Action |
|-----|--------|
| `vv` | Edit command in `$EDITOR` |
| `e` | Edit command in vim *(custom)* |
| Standard vi motions | `h/l` move cursor, `w/b/e` word movement, `0/$` line start/end, etc. |
| `p` / `P` | Paste from clipboard |
| `y` + motion | Yank to clipboard |
| `d` + motion | Delete to clipboard |
| `c` + motion | Change to clipboard |

#### Insert mode

| Key | Action |
|-----|--------|
| `Ctrl-P` | Previous history entry |
| `Ctrl-N` | Next history entry |
| `Ctrl-R` | Incremental history search backward |
| `Ctrl-S` | Incremental history search forward |
| `Ctrl-A` | Move to beginning of line |
| `Ctrl-E` | Move to end of line |
| `Ctrl-W` | Delete word backward |
| `Ctrl-H` / `Backspace` | Delete character backward |

### History substring search (oh-my-zsh plugin)

Searches only within history entries that match what you've already typed.

| Key | Action |
|-----|--------|
| `↑` | Search history backward (substring match) |
| `↓` | Search history forward (substring match) |

### zsh-autosuggestions

Suggestions appear greyed out as you type, based on history.

| Key | Action |
|-----|--------|
| `→` or `End` | Accept full suggestion |
| `Alt+→` or word-forward motion | Accept suggestion up to next word |
| Any history navigation key | Clear suggestion |

### Completion menu

Active when a completion menu is open (`Tab` to open).

| Key | Action |
|-----|--------|
| `Space` | Accept and infer next history entry |
| `Backspace` | Undo last completion |
| Arrow keys | Navigate menu |
| `Tab` | Next completion |
| `Shift+Tab` | Previous completion |

### Custom bindings (`keybinds.zsh`)

| Key | Action |
|-----|--------|
| `Alt+←` | Backward word |
| `Alt+→` | Forward word |
