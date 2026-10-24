# dotfiles

My macOS setup: apps and CLIs (Homebrew), languages (mise), shell, git, VS Code and macOS preferences.

Requires a Mac with Apple Silicon and macOS 14 or later.

## Setup

In Terminal:

1. Sign in to the App Store (only needed for Xcode).

2. Install Homebrew. It also installs Apple's Command Line Tools, which include `git`.

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   Ignore the "Next steps" it prints at the end; `install.sh` does them.

3. Clone and run:

   ```sh
   git clone https://github.com/odanieldcs/dotfiles.git ~/code/dev/dotfiles
   ~/code/dev/dotfiles/install.sh
   ```

   It asks a few questions and your password first, then installs everything and prints a summary. It is safe to run again; `--yes` skips the questions.

4. Do the manual steps in [docs/workflow.md](docs/workflow.md#after-install).

## What's inside

| Path                | Sets up                                                                  |
| ------------------- | ------------------------------------------------------------------------ |
| `Brewfile`          | apps, CLIs and fonts                                                     |
| `mise/`             | Node, pnpm, Python and Go                                                |
| `zsh/`, `starship/` | shell, PATH and prompt                                                   |
| `git/`, `ssh/`      | git, global gitignore, SSH                                               |
| `vscode/`           | VS Code settings and extensions                                          |
| `aws/`, `npm/`      | starting configs, copied once (not linked) because they hold credentials |
| `macos.sh`          | Finder, keyboard, trackpad, Dock, firewall, Touch ID for `sudo`          |

## Docs

- [Workflow](docs/workflow.md): after install and day to day
- [Work profile](docs/work-profile.md): adding a company setup

## License

[MIT](LICENSE). To reuse it, fork and change `git/config` (name, email), the `Brewfile` and `vscode/extensions.json`.
