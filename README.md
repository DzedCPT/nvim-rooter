# Nvim-Rooter

`nvim-rooter` is a Neovim plugin that automatically changes your working directory to the project root based on a set of configured rules. The goal is to be a perfect clone of [vim-rooter](https://github.com/airblade/vim-rooter) but written in Lua. 

> [!WARNING]  
> nvim-rooter is functional but a work in progress and doesn't yet perfectly mimic vim-rooter's behaviour.
> 


Why use `nvim-rooter` instead of `vim-rooter`? To avoid the ignominy of running VimScript in 2024. So if you're a person with any dignity you should just use nvim-rooter. No, in all seriousness, you should probably use [vim-rooter](https://github.com/airblade/vim-rooter), it's a better plugin and so simple the downsides of VimScript don't really apply to it.

## Configuration

```lua
{
  -- cmd used to change working dir:
  rooter_cd_cmd = "cd", -- "cd" | "lcd" | "tcd"
  -- If false will print new cwd with cwd is changed
  rooter_silent_chdir = true,
  -- Set to true to only run nvim-rooter manually
  rooter_manual_only = false,
  -- Which buffer types trigger Rooter: normal buffers have buftype ""
  rooter_buftypes = { "" },
  -- Table of files whose presence signifies project root
  rooter_patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
}
```

## Commands

nvim-rooter defines a user command `Root` to manually trigger changing the working directory to the project root. 
