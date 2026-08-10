Dotfiles
---

This repo is managed by [mise](https://mise.jdx.dev/dotfiles.html).

## Layout

- `mise.toml` - shared config: `[dotfiles]` entries, which are symlinked to `~/.config/mise/config.toml` on apply which makes the config a global mise config.
- `mise.<machine>.toml` - per machine config `[tools]`, machine-only dotfiles, packages, and the `machine` template var. Selected via `MISE_ENV`.
- `home/` - the dotfiles sources. Contains most of the symlinks into `$HOME` (`symlink-each` for `~/.config`); `*.tmpl` files are rendered with the mise template engine `~/.gitconfig`, `~/.ssh/config`).

## Machines

 Machine   | Device                | Shell | Packages                     |
| --------- | --------------------- | ----- | ---------------------------- |
| `macos`   | Laptop (macOS)        | zsh  | Homebrew                     |

The machine is pinned once per host in `~/.config/mise/miserc.toml` (untracked):

```sh
mkdir -p ~/.config/mise
printf 'env = ["fedora"]\n' > ~/.config/mise/miserc.toml   # or macos
```

It selects the `mise.<machine>.toml` overlay, which determines the shell config to lay down, the mise tool list, and the package hooks. Git identity defaults live in `[vars]` in `mise.toml`; override them per host in an untracked `mise.local.toml` next to `mise.toml`

## Bootstrap

mise itself is always installed with the official installer, on every platform - never through a package manager. Package-manager copies (brew, pkg, rpm-ostree) can't `mise self-update` and lags behind releases. The installer puts the binary at `~/.local/bin/mise` (override with `MISE_INSTALL_PATH`), and the shell configs in this repo already put `~/.local/bin` first on `PATH`.

Common flow, after the machine-specific preparation below:

```sh
curl https://mise.run | sh   # installs ~/.local/bin/mise
git clone https://github.com/mattkgwhite/dotfiles ~/.dotfiles
cd ~/.dotfiles
mise trust
mkdir -p ~/.config/mise
printf 'env = ["<machine>"]\n' > ~/.config/mise/miserc.toml
mise bootstrap --yes
# chmod 600 ~/.ssh/config
```

`mise bootstrap` clones the declared repos, applies the dotfiles (including symlinking this repo's `mise.toml` into `~/.config/mise/config.toml`), installs the declared `[tools]`, and runs any tasks configured. Re-run it (or `mise dotfiles apply`) after pulling changes. the `chmod` is needed because git does not track the 0600 mode on the ssh config source.

## macos

Homebrew is still needed for the brewfile, but not for mise:

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

Then run the common flow. The post-dotfiles hook installs everything in the brewfile on each bootstrap (`--no-upgrade`, so it only installs what is missing).

## Notes

- Machine identity lives in `~/.config/mise/miserc.toml`; git identity overrides live in `mise.local.toml`. Neither is tracked in this repo.
- Most deployed files are symlinks into the repo, so editing the deployed file edits the repo checkout. Rendered templates (`~/.gitconfig` and `~/.ssh/config`) need `mise dotfiles apply` after editing their `.tmpl` source.
- `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` are symlinks to the same agents file as `~/.config/agents/AGENTS.md`, so Claude Code and Codex share
  one set of global agent instructions.
- `mise dotfiles status` shows what is applied, missing, or drifted;
  `mise bootstrap status` covers packages, repos, and tools too.