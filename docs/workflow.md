# Workflow

## After install

Things `install.sh` can't do for you, in order.

**GitHub**

- [ ] `gh auth login --git-protocol ssh --web` and accept uploading `~/.ssh/id_ed25519.pub`
- [ ] Switch this repo to SSH: `git -C ~/code/dev/dotfiles remote set-url origin git@github.com:odanieldcs/dotfiles.git`
- [ ] github.com → Settings → Emails: turn on "Keep my email addresses private" and "Block command line pushes that expose my email"

**Editors and terminal**

- [ ] VS Code: keep Settings Sync **off**. Settings come from `vscode/settings.json`, and Sync would overwrite them
- [ ] Dracula Pro (paid `.vsix`, kept out of this public repo): `code --install-extension <file>.vsix`
- [ ] Cursor: accept the import from VS Code on first launch, then `cursor --install-extension <file>.vsix` for Dracula Pro. Cursor downloads extensions from Open VSX, where anyone can publish under an unclaimed name: check that each one shows the same publisher as on the VS Code Marketplace
- [ ] Warp → Settings → Appearance → Input type: **Shell (PS1)**, so it shows the starship prompt

**Mobile**

- [ ] Android Studio: open it once and install SDK Platform 35, Build-Tools 36 and the Command-line Tools (React Native requirements)
- [ ] iOS simulator, when needed: `xcodebuild -downloadPlatform iOS` (~8 GB)

**Accounts**

- [ ] AWS: `aws configure sso` if the account has IAM Identity Center; otherwise put the keys in `~/.aws/credentials`
- [ ] Sign in and add licenses: Dia, Chrome, Bitwarden, Docker Desktop, CleanShot, TablePlus, Slack…

**Last**

- [ ] Log out and back in, so the keyboard and trackpad settings apply

## Day to day

Run these from `~/code/dev/dotfiles`; `brew bundle` reads the `Brewfile` in the current folder.

| I want to…                                      | Do                                                                                           |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Install a new app or CLI                        | add it to the `Brewfile`, then `brew bundle`                                                 |
| See what is installed but not in the `Brewfile` | `brew bundle cleanup` (only lists; `--force` uninstalls)                                     |
| Update everything                               | `brew update && brew upgrade` and `mise upgrade`                                             |
| Use another Node/Python/Go version in a project | `mise use node@22` inside the project (writes a `mise.toml`)                                 |
| Add a VS Code extension                         | add its id to `vscode/extensions.json`, then `./install.sh --yes`                            |
| Refresh the extension list from VS Code         | `code --list-extensions \| jq -R . \| jq -s '{recommendations: .}' > vscode/extensions.json` |
| Change zsh, git, starship or VS Code settings   | edit the file in `~` or here, it's the same file; then commit                                |
| Re-apply the whole setup                        | `./install.sh --yes`                                                                         |

Projects pinned with Volta (`"volta"` in `package.json`) need a `.node-version` file; mise reads it, along with `.nvmrc` and the `packageManager` field.

## Linked vs copied

|             | Files                                                                                                | Where to edit                                                                                 |
| ----------- | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Linked      | `.zshrc`, `.zprofile`, git config, `.gitignore_global`, mise, ssh config, starship, VS Code settings | anywhere: `~` and the repo point to the same file                                             |
| Copied once | `~/.npmrc`, `~/.aws/config`, `~/.aws/credentials`                                                    | only in `~`. Tools write tokens and keys into them, so they never point into this public repo |

Shell secrets go in `~/.zshrc.local`, which is not versioned.
