# Work profile

Adds a company setup next to the personal one: its own git identity, SSH key, runtime versions, env vars and apps, all scoped to `~/code/work/<company>`.
Company data stays out of this public repo: the only change here is a generic path in `git/config`.

The examples use `acme`; replace it with the company name.

## Setting up

1. **Folder**

   ```sh
   mkdir -p ~/code/work/acme
   ```

2. **Git identity.** Add to `git/config` in this repo (generic on purpose, no company name):

   ```ini
   [includeIf "gitdir:~/code/work/"]
     path = ~/.config/git/work
   ```

   Then create `~/.config/git/work`, which is not versioned:

   ```ini
   [user]
     email = daniel@acme.com
   ```

   Check it inside any company repo: `git config user.email`.

3. **SSH key**

   ```sh
   ssh-keygen -t ed25519 -C daniel@acme.com -f ~/.ssh/id_ed25519_acme
   ```

   Add the public key (`~/.ssh/id_ed25519_acme.pub`) to your company GitHub account, and this block to `~/.ssh/config.local`:

   ```
   Host github-acme
     HostName github.com
     IdentityFile ~/.ssh/id_ed25519_acme
     IdentitiesOnly yes
   ```

   Clone with the alias instead of `github.com`: `git clone git@github-acme:acme/repo.git`.

4. **Versions and env vars.** Create `~/code/work/acme/mise.toml`. It applies to every project inside that folder; run `mise trust` there once.

   ```toml
   [tools]
   node = "20"

   [env]
   AWS_PROFILE = "acme"
   ```

5. **AWS.** Add a `[profile acme]` section to `~/.aws/config` (or run `aws configure sso --profile acme`). With access keys instead of SSO, also add an `[acme]` section with them to `~/.aws/credentials`.

6. **Apps.** List them in `~/code/work/acme/Brewfile` and install:

   ```sh
   brew bundle --file=~/code/work/acme/Brewfile
   ```

   VS Code extensions the company needs belong in each project's `.vscode/extensions.json`; VS Code offers to install them when you open the project.

## Removing the work folder

1. Delete the SSH key from the company GitHub account, then remove it locally: `rm ~/.ssh/id_ed25519_acme*`
2. Remove the `github-acme` block from `~/.ssh/config.local`.
3. Remove the `acme` sections from `~/.aws/config` and `~/.aws/credentials`.
4. Uninstall the company apps. List first, then run again with `--force`:

   ```sh
   brew bundle cleanup --file=~/code/dev/dotfiles/Brewfile
   ```

5. Delete the folder and the git identity: `rm -rf ~/code/work/acme ~/.config/git/work`
6. If no other company is left, remove the `includeIf` block from `git/config`.
