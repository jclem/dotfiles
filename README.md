# dotfiles

My dotfiles, managed by [Mise](https://mise.jdx.dev/).

## Setup

This configuration expects an Apple Silicon Mac with Homebrew and Mise
installed.

```sh
mkdir -p ~/src/github.com/jclem
git clone https://github.com/jclem/dotfiles.git ~/src/github.com/jclem/dotfiles
cd ~/src/github.com/jclem/dotfiles
mise trust
mise bootstrap --force-dotfiles
```

Run `reload` from Fish to apply the configuration again.

See the Mise documentation for
[bootstrap](https://mise.jdx.dev/bootstrap.html) and
[dotfiles](https://mise.jdx.dev/dotfiles.html).
