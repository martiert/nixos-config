{config, pkgs, ...}:

{
  programs.neovim = {
    enable = true;

    vimAlias = true;
    vimdiffAlias = true;

    withRuby = false;

    coc = {
      enable = true;
    };

    plugins = with pkgs.vimPlugins; [
      ctrlp
      fugitive
      cpsm
      rainbow

      LanguageClient-neovim

      coc-tsserver
      coc-pyright
      vim-nix
    ];

    extraConfig = ''
      colorscheme desert

      set nocompatible
      set expandtab
      set list
      set listchars=tab:>-
      set number
      set shiftwidth=4
      set softtabstop=4
      set tabstop=4
  
      au BufNewFile,BufRead genmake.def     set syntax=python
      au BufNewFile,BufRead genmake.def     setfiletype python
      au BufNewFile,BufRead *.nix           setfiletype nix
      au BufNewFile,BufRead *.ts            setfiletype javascript
      au BufNewFile,BufRead *.tsx           setfiletype javascript
  
      filetype plugin indent on
      autocmd FileType typescript,javascript,html,xml,tex,nix setlocal shiftwidth=2 softtabstop=2
  
      let g:rainbow_active = 1
      let g:rainbow_conf = {
        \   'ctermfgs': [
        \     'darkcyan',
        \     'green',
        \     'yellow',
        \     'red',
        \     'darkmagenta',
        \   ]
        \ }
  
      let g:LanguageClient_serverCommands = {
        \ 'cpp': ['${pkgs.ccls}/bin/ccls'],
        \ 'c': ['${pkgs.ccls}/bin/ccls'],
        \ 'python': ['pylsp'],
        \ 'js': ['javascript-typescript-langserver', '--strict'],
        \ }
      nmap <silent> gd <Plug>(lcn-definition)
      nmap <silent> gr <Plug>(lcn-references)
      nmap <silent> gi <Plug>(lcn-implementation)
      nmap <silent> gmv <Plug>(lcn-rename)
      nmap <silent>K <Plug>(lcn-hover)
    '';
  };
}
