# dotfiles

My macOS setup in one script: apps and CLIs, languages, shell, git, VS Code and basic macOS preferences.

Requires a Mac with Apple Silicon running macOS 14 (Sonoma) or later.

## Install

Sign in to the App Store first if you want Xcode, then:

```sh
# 1. Homebrew (also installs git)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Clone and run
git clone https://github.com/odanieldcs/dotfiles.git ~/code/dev/dotfiles
~/code/dev/dotfiles/install.sh
```

The script asks its questions and your password at the start (SSH key, macOS preferences, Xcode), then runs on its own and ends with a summary. It is safe to run again; `install.sh --yes` accepts every default.

## What's inside

| Path                | Sets up                                                                  |
| ------------------- | ------------------------------------------------------------------------ |
| `Brewfile`          | apps, CLIs and fonts, through Homebrew                                   |
| `mise/`             | Node, pnpm, Python and Go versions                                       |
| `zsh/`, `starship/` | shell, PATH and prompt                                                   |
| `git/`, `ssh/`      | git config, global gitignore, SSH                                        |
| `vscode/`           | VS Code settings and extensions                                          |
| `aws/`, `npm/`      | starting configs, copied once so tokens and keys never land in this repo |
| `macos.sh`          | Finder, keyboard, trackpad, Dock, firewall, Touch ID for `sudo`          |

## Docs

- [Workflow](docs/workflow.md): what to do after install, and day-to-day commands
- [Work profile](docs/work-profile.md): adding a company setup next to the personal one

## Using it yourself

Fork it, then change the name and email in `git/config`, and the apps in `Brewfile` and `vscode/extensions.json`.

## License

[MIT](LICENSE): use, copy and change it freely, keeping the copyright notice. The license covers the files in this repo, not the apps the `Brewfile` installs; each app has its own license.
