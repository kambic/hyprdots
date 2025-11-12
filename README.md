Dotfiles Template
=================

This is a template repository for bootstrapping your dotfiles with [Dotbot][dotbot].

To get started, you can [create a new repository from this template][template]
(or you can [fork][fork] this repository, if you prefer). You can probably
delete this README and rename your version to something like just `dotfiles`.

In general, you should be using symbolic links for everything, and using git
submodules whenever possible.

To keep submodules at their proper versions, you could include something like
`git submodule update --init --recursive` in your `install.conf.yaml`.

To upgrade your submodules to their latest versions, you could periodically run
`git submodule update --init --remote`.

Inspiration
-----------

# Modern CLI tools
yay -S exa bat duf procs fd fzf
