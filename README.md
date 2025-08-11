# jclem/dotfiles

This project contains my personal dotfiles and Codespaces configuration, managed
by [chezmoi](https://chezmoi.io).

## Usage

### Install

Install nix:

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Set up dotfiles with chezmoi:

```shell
sh -c "$(curl -fsLS git.io/chezmoi)" -- init --apply jclem
```

### Update

```shell
chezmoi update
```