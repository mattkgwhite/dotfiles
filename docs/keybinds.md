# Keyboard shortcuts

Reference for all active keybindings across Ghostty, tmux, and zsh.

---

## Ghostty

No custom keybinds are defined; these are all defaults. Since Ghostty starts tmux on launch, native split/tab commands go through tmux in practice, but Ghostty-level window management still works.

### How to list keybinds

Open the command palette with `Cmd+Shift+P` and search for actions, or see the full reference at <https://ghostty.org/docs/config/keybind/reference>.

### How to modify keybinds

Edit the source file, then apply:

```sh
# Source file (chezmoi-managed)
~/.local/share/chezmoi/home/dot_config/ghostty/config

# After editing:
chezmoi apply
```

Format: `keybind = trigger=action` (e.g. `keybind = cmd+k=clear_screen`). See <https://ghostty.org/docs/config/keybind>.

### Clipboard

| Key           | Action               |
|---------------|----------------------|
| `Cmd+C`       | Copy to clipboard    |
| `Cmd+V`       | Paste from clipboard |
| `Cmd+Shift+V` | Paste from selection |
| `Cmd+A`       | Select all           |

### Windows & tabs

| Key              | Action                           |
|------------------|----------------------------------|
| `Cmd+N`          | New window                       |
| `Cmd+W`          | Close surface (split/tab/window) |
| `Cmd+Alt+W`      | Close tab                        |
| `Cmd+Shift+W`    | Close window                     |
| `Cmd+T`          | New tab                          |
| `Cmd+Shift+[`    | Previous tab                     |
| `Cmd+Shift+]`    | Next tab                         |
| `Ctrl+Shift+Tab` | Previous tab                     |
| `Ctrl+Tab`       | Next tab                         |
| `Cmd+1`-`Cmd+8`  | Go to tab 1-8                    |
| `Cmd+9`          | Go to last tab                   |

### Splits (native Ghostty splits, not tmux)

| Key                           | Action                        |
|-------------------------------|-------------------------------|
| `Cmd+D`                       | New split right               |
| `Cmd+Shift+D`                 | New split down                |
| `Cmd+[`                       | Previous split                |
| `Cmd+]`                       | Next split                    |
| `Cmd+Alt+Up/Down/Left/Right`  | Go to split in direction      |
| `Cmd+Ctrl+Up/Down/Left/Right` | Resize split                  |
| `Cmd+Ctrl+=`                  | Equalize splits               |
| `Cmd+Shift+Enter`             | Toggle split zoom             |
| `Cmd+Enter`                   | Toggle fullscreen             |
| `Cmd+Ctrl+F`                  | Toggle fullscreen (alternate) |

### Font & display

| Key               | Action             |
|-------------------|--------------------|
| `Cmd+=` / `Cmd++` | Increase font size |
| `Cmd+-`           | Decrease font size |
| `Cmd+0`           | Reset font size    |
| `Cmd+K`           | Clear screen       |

### Search

| Key                      | Action                 |
|--------------------------|------------------------|
| `Cmd+F`                  | Start search           |
| `Cmd+G`                  | Next search result     |
| `Cmd+Shift+G`            | Previous search result |
| `Cmd+Shift+F` / `Escape` | End search             |
| `Cmd+E`                  | Search selection       |

### Scrollback

| Key                           | Action                  |
|-------------------------------|-------------------------|
| `Cmd+Home`                    | Scroll to top           |
| `Cmd+End`                     | Scroll to bottom        |
| `Cmd+Page Up`                 | Scroll page up          |
| `Cmd+Page Down`               | Scroll page down        |
| `Cmd+J`                       | Scroll to selection     |
| `Cmd+Up` / `Cmd+Shift+Up`     | Jump to previous prompt |
| `Cmd+Down` / `Cmd+Shift+Down` | Jump to next prompt     |

### Screen capture

| Key                | Action                         |
|--------------------|--------------------------------|
| `Cmd+Shift+J`      | Write screen to file and paste |
| `Cmd+Ctrl+Shift+J` | Write screen to file and copy  |
| `Cmd+Alt+Shift+J`  | Write screen to file and open  |

### Config

| Key           | Action           |
|---------------|------------------|
| `Cmd+,`       | Open config      |
| `Cmd+Shift+,` | Reload config    |
| `Cmd+Shift+P` | Command palette  |
| `Cmd+Alt+I`   | Toggle inspector |

### Line editing (passthrough to shell)

| Key             | Action                             |
|-----------------|------------------------------------|
| `Cmd+Right`     | Move to end of line (`^E`)         |
| `Cmd+Left`      | Move to beginning of line (`^A`)   |
| `Cmd+Backspace` | Delete to beginning of line (`^U`) |
| `Alt+Right`     | Forward word                       |
| `Alt+Left`      | Backward word                      |

---

## tmux

**Prefix: `Ctrl-a`**

Stock tmux bindings (`Ctrl-b`) are disabled. All bindings below require the prefix unless marked *(no prefix)*.

### How to list keybinds

```sh
# In a tmux session:
Ctrl-a ?          # interactive list (press q to exit)

# From the shell:
tmux list-keys
tmux list-keys -T copy-mode-vi
```

### How to modify keybinds

Edit the local override file, then reload config (`Ctrl-a r`):

```sh
# Source file (chezmoi-managed)
~/.local/share/chezmoi/home/dot_config/tmux/tmux.conf.local

# After editing:
chezmoi apply
# Config is reloaded automatically on apply; or reload manually:
tmux source ~/.config/tmux/tmux.conf.local
```

Do not modify `~/.tmux.conf` (oh-my-tmux base) or `~/.tmux.conf.local` directly; they are symlinked/managed by chezmoi. All custom bindings go in `tmux.conf.local`.

### Sessions

| Key                | Action                          |
|--------------------|---------------------------------|
| `Ctrl-a Ctrl-c`    | New session                     |
| `Ctrl-a Ctrl-f`    | Find/switch session by name     |
| `Ctrl-a Shift-Tab` | Switch to last session          |
| `Ctrl-a s`         | Interactive session/window tree |
| `Ctrl-a $`         | Rename session                  |
| `Ctrl-a d`         | Detach                          |
| `Ctrl-a (`         | Previous client                 |
| `Ctrl-a )`         | Next client                     |
| `Ctrl-a D`         | Choose client to detach         |
| `Ctrl-a C-z`       | Suspend client                  |

### Windows

| Key                   | Action                           |
|-----------------------|----------------------------------|
| `Ctrl-a c`            | New window                       |
| `Ctrl-a Tab`          | Last active window               |
| `Ctrl-a Ctrl-h`       | Previous window *(repeatable)*   |
| `Ctrl-a Ctrl-l`       | Next window *(repeatable)*       |
| `Ctrl-a Ctrl-Shift-H` | Swap window left *(repeatable)*  |
| `Ctrl-a Ctrl-Shift-L` | Swap window right *(repeatable)* |
| `Ctrl-a 0`-`9`        | Go to window by number           |
| `Ctrl-a '`            | Go to window by number (prompt)  |
| `Ctrl-a ,`            | Rename window                    |
| `Ctrl-a .`            | Move window (prompt for target)  |
| `Ctrl-a f`            | Find window by content           |
| `Ctrl-a w`            | Interactive window/session tree  |
| `Ctrl-a &`            | Kill window (with confirmation)  |
| `Ctrl-a M-n`          | Next window with alert           |
| `Ctrl-a M-p`          | Previous window with alert       |
| `Ctrl-a M-o`          | Rotate windows                   |
| `Ctrl-a C-o`          | Rotate panes in window           |

### Panes

| Key                           | Action                                  |
|-------------------------------|-----------------------------------------|
| `Ctrl-a -`                    | Split pane top/bottom                   |
| `Ctrl-a _`                    | Split pane left/right                   |
| `Ctrl-a h/j/k/l`              | Select pane left/down/up/right          |
| `Ctrl-a Up/Down/Left/Right`   | Select pane in direction *(repeatable)* |
| `Ctrl-a H/J/K/L`              | Resize pane by 2 *(repeatable)*         |
| `Ctrl-a C-Up/Down/Left/Right` | Resize pane by 1 *(repeatable)*         |
| `Ctrl-a M-Up/Down/Left/Right` | Resize pane by 5 *(repeatable)*         |
| `Ctrl-a o`                    | Cycle to next pane                      |
| `Ctrl-a ;`                    | Last active pane                        |
| `Ctrl-a >`                    | Swap pane with next                     |
| `Ctrl-a <`                    | Swap pane with previous                 |
| `Ctrl-a {`                    | Swap pane with previous (stock)         |
| `Ctrl-a }`                    | Swap pane with next (stock)             |
| `Ctrl-a +`                    | Maximize/restore pane                   |
| `Ctrl-a z`                    | Toggle pane zoom                        |
| `Ctrl-a !`                    | Break pane into new window              |
| `Ctrl-a q`                    | Display pane numbers                    |
| `Ctrl-a x`                    | Kill pane (with confirmation)           |
| `Ctrl-a M`                    | Toggle marked pane                      |
| `Ctrl-a Space`                | Cycle to next layout                    |
| `Ctrl-a E`                    | Equalize pane sizes                     |
| `Ctrl-a M-1`                  | Layout: even-horizontal                 |
| `Ctrl-a M-2`                  | Layout: even-vertical                   |
| `Ctrl-a M-3`                  | Layout: main-horizontal                 |
| `Ctrl-a M-4`                  | Layout: main-vertical                   |
| `Ctrl-a M-5`                  | Layout: tiled                           |
| `Ctrl-a i`                    | Show pane info                          |

### Copy mode (vi bindings)

Enter with `Ctrl-a Enter`. Uses `copy-mode-vi` key table.

#### Navigation

| Key               | Action                                                     |
|-------------------|------------------------------------------------------------|
| `h/j/k/l`         | Cursor left/down/up/right                                  |
| `w/W`             | Next word start (word/WORD)                                |
| `b/B`             | Previous word start (word/WORD)                            |
| `e/E`             | Next word end (word/WORD)                                  |
| `0` / `^`         | Start of line / first non-blank                            |
| `$`               | End of line                                                |
| `H`               | Start of line *(oh-my-tmux: remapped from top-of-screen)*  |
| `L`               | End of line *(oh-my-tmux: remapped from bottom-of-screen)* |
| `M`               | Middle line on screen                                      |
| `g` / `G`         | Top / bottom of history                                    |
| `:`               | Go to line (prompt)                                        |
| `{` / `}`         | Previous / next paragraph                                  |
| `%`               | Jump to matching bracket                                   |
| `f<c>` / `F<c>`   | Jump forward/backward to character                         |
| `t<c>` / `T<c>`   | Jump forward/backward before character                     |
| `;` / `,`         | Repeat last jump / reverse last jump                       |
| `C-u` / `C-d`     | Half page up/down                                          |
| `C-b` / `C-f`     | Page up/down                                               |
| `C-e` / `C-y`     | Scroll down/up one line                                    |
| `J` / `K`         | Scroll down/up *(oh-my-tmux bindings)*                     |
| `z`               | Centre view on cursor                                      |
| `PPage` / `NPage` | Page up/down                                               |

#### Selection & copy

| Key            | Action                                   |
|----------------|------------------------------------------|
| `v` / `Space`  | Begin selection                          |
| `V`            | Select entire line                       |
| `Ctrl-v`       | Toggle rectangle selection               |
| `o`            | Move to other end of selection           |
| `y` / `Enter`  | Copy selection and exit copy mode        |
| `C-j`          | Copy selection (stay in copy mode)       |
| `A`            | Append selection and exit copy mode      |
| `D`            | Copy from cursor to end of line and exit |
| `Escape` / `q` | Cancel / exit copy mode                  |

#### Search

| Key       | Action                                         |
|-----------|------------------------------------------------|
| `/`       | Search forward (prompt)                        |
| `?`       | Search backward (prompt)                       |
| `n` / `N` | Next / previous match                          |
| `*`       | Search forward for word under cursor           |
| `#`       | Search backward for word under cursor          |
| `C-r`     | Incremental search backward *(copy-mode only)* |
| `C-s`     | Incremental search forward *(copy-mode only)*  |

#### Marks

| Key   | Action       |
|-------|--------------|
| `X`   | Set mark     |
| `M-x` | Jump to mark |

### Paste buffers

| Key                     | Action                               |
|-------------------------|--------------------------------------|
| `Ctrl-a p` / `Ctrl-a ]` | Paste from top buffer                |
| `Ctrl-a P`              | Choose buffer to paste (basic list)  |
| `Ctrl-a =`              | Choose buffer to paste (interactive) |
| `Ctrl-a b` / `Ctrl-a #` | List paste buffers                   |
| `Ctrl-a y`              | Yank top buffer to system clipboard  |

### Utilities

| Key                    | Action                                               |
|------------------------|------------------------------------------------------|
| `Ctrl-a r`             | Reload tmux config                                   |
| `Ctrl-a e`             | Open file in nvim in a split (prompts for filename)  |
| `Ctrl-a /`             | Open man page in a split (prompts for page name)     |
| `Ctrl-a m`             | Toggle mouse mode                                    |
| `Ctrl-a F`             | Launch fpp (file path picker)                        |
| `Ctrl-a t`             | Show clock                                           |
| `Ctrl-a :`             | Command prompt                                       |
| `Ctrl-a ?`             | List all keybindings                                 |
| `Ctrl-a ~`             | Show message log                                     |
| `Ctrl-a C-a`           | Send prefix through to shell (pass-through `Ctrl-a`) |
| `Ctrl-L` *(no prefix)* | Clear screen and scrollback history                  |

---

## zsh

### How to list keybinds

```sh
# List all keymaps
bindkey -l

# List bindings in a specific keymap
bindkey -M vicmd   # normal mode
bindkey -M viins   # insert mode
bindkey -M menuselect  # completion menu

# List all ZLE widgets (including custom ones)
zle -al

# Show what a specific key is bound to
bindkey -M vicmd 'e'
```

### How to modify keybinds

Edit the keybinds file, then reload zsh or source the file:

```sh
# Source file (chezmoi-managed)
~/.local/share/chezmoi/home/dot_config/zsh/dot_zshrc.d/keybinds.zsh

# After editing:
chezmoi apply
source ~/.config/zsh/.zshrc.d/keybinds.zsh  # or open a new shell
```

Format: `bindkey -M <keymap> '<keys>' <widget>`. Custom widgets must be defined with `zle -N <widget> <function>` before binding. See `man zshzle`.

### vi mode

zsh runs in vi mode (from `oh-my-zsh/vi-mode`). Press `Esc` to enter normal mode; `i` or `a` to return to insert.

#### Normal mode (vicmd)

| Key                 | Action                                                               |
|---------------------|----------------------------------------------------------------------|
| `vv`                | Edit command in `$EDITOR` *(see note below)*                         |
| `e`                 | Edit command in vim *(custom)*                                       |
| Standard vi motions | `h/l` move cursor, `w/b/e` word movement, `0/$` line start/end, etc. |
| `p` / `P`           | Paste from clipboard                                                 |
| `y` + motion        | Yank to clipboard                                                    |
| `d` + motion        | Delete to clipboard                                                  |
| `c` + motion        | Change to clipboard                                                  |

> **Note on `vv`:** This requires two `v` keypresses within `$KEYTIMEOUT` milliseconds (zsh default: 40ms). With the default timeout it is nearly impossible to trigger reliably because the first `v` dispatches immediately to `visual-mode`. Raising `KEYTIMEOUT` to 15+ makes it usable. The `e` binding is provided as a single-keystroke alternative that avoids this issue entirely.

#### Insert mode

| Key                    | Action                              |
|------------------------|-------------------------------------|
| `Ctrl-P`               | Previous history entry              |
| `Ctrl-N`               | Next history entry                  |
| `Ctrl-R`               | Incremental history search backward |
| `Ctrl-S`               | Incremental history search forward  |
| `Ctrl-A`               | Move to beginning of line           |
| `Ctrl-E`               | Move to end of line                 |
| `Ctrl-W`               | Delete word backward                |
| `Ctrl-H` / `Backspace` | Delete character backward           |

### History substring search (oh-my-zsh plugin)

Searches only within history entries that match what you've already typed.

| Key    | Action                                    |
|--------|-------------------------------------------|
| `Up`   | Search history backward (substring match) |
| `Down` | Search history forward (substring match)  |

### zsh-autosuggestions

Suggestions appear greyed out as you type, based on history.

| Key                                | Action                            |
|------------------------------------|-----------------------------------|
| `Right` or `End`                   | Accept full suggestion            |
| `Alt+Right` or word-forward motion | Accept suggestion up to next word |
| Any history navigation key         | Clear suggestion                  |

### Completion menu

Active when a completion menu is open (`Tab` to open).

| Key         | Action                              |
|-------------|-------------------------------------|
| `Space`     | Accept and infer next history entry |
| `Backspace` | Undo last completion                |
| Arrow keys  | Navigate menu                       |
| `Tab`       | Next completion                     |
| `Shift+Tab` | Previous completion                 |

### Custom bindings (`keybinds.zsh`)

| Key         | Action        |
|-------------|---------------|
| `Alt+Left`  | Backward word |
| `Alt+Right` | Forward word  |
