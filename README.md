rogue.vim
=========

*"Hello Vimmer, welcome to the Dungeons of Doom..."*

![image](https://raw.githubusercontent.com/wiki/katono/rogue.vim/image/rogue_vim.png)


## Description

This Vim plugin is a game that is porting of Rogue-clone II.
You can enjoy the game on your Vim.
This rogue-clone is message-separated, and so you can make your original message file.

By the way, you can get the original of this game from FreeBSD ports `japanese/rogue_s`.


## Repository

You can get the latest version from here.

https://github.com/katono/rogue.vim


## Requirements

rogue.vim requires Lua-enabled Vim or neovim.
Please make sure that at least one of the following conditions is met.

- `:echo has('lua')` returns 1 and `:echo luaeval('_VERSION')` returns `Lua 5.1` or later.
- `:echo has('nvim')` returns 1 and `:echo luaeval('_VERSION')` returns `Lua 5.1` or later.
- `:echo has('vim9script')` returns 1 and `has('patch-8.2.4161')` returns 1.
    - Recommend Vim 9.1.0850 or later, as `:class` is sufficiently supported.

LuaJIT is recommended because that is very fast.


## Installation

Copy `autoload`, `doc`, `plugin`, and `syntax` directories into your Vim runtimepath,
like `$HOME/.vim` or `$VIM/vimfiles`.
And execute this Vim command to make help tags.

    :helptags <installed directory>/doc

You can execute `:h rogue` to see this plugin's help.

If you use a Vim plugin manager, follow its way.


## License

MIT License


