# vim baidu translator

vim baidu translater 是一个利用百度翻译API制作的vim插件，可以帮你在 vim 中翻译单词或语句

## 安装

### 普通安装:
把 `baidu_translator.vim` 文件拷贝到 `~/.vim/plugin` 目录下，就可以用了。


### pathogen 安装：
如果装有 pathogen 可以 :

	cd ~/.vim/bundle
	git clone https://github.com/ketor/vim-baidu-translator.git


###  配置
添加 `~/.vimrc` 文件：

Without Baidu appid/secretKey

```vim
vnoremap <silent> <C-T> :<C-u>Bdv<CR>
nnoremap <silent> <C-T> :<C-u>Bdc<CR>

nnoremap <leader>bd :<C-u>Bdc<CR>
vnoremap <leader>bd :<C-u>Bdv<CR>
```

With Baidu appid/secretKey

```vim
let g:baidu_appid=YourAppId
let g:baidu_secretKey=YourSecretKey

vnoremap <silent> <C-T> :<C-u>Bdv<CR>
nnoremap <silent> <C-T> :<C-u>Bdc<CR>

nnoremap <leader>bd :<C-u>Bdc<CR>
vnoremap <leader>bd :<C-u>Bdv<CR>
```

如果没有配置百度的appid和secretKey，插件将会直接访问百度Web端解析，未来如果百度改变了web api的接口则可能查不到结果。

## 如何使用

在普通模式下，按 `ctrl+t`， 会翻译当前光标下的单词；

在 `visual` 模式下选中单词或语句，按 `ctrl+t`，会翻译选择的单词或语句；

点击引导键再点b，d，可以在命令行输入要翻译的单词或语句；

译文将会在编辑器底部的命令栏显示。



## License

The MIT License (MIT)

Copyright (c) ketor


## 备注

基于ianva的vim-youdao-translater插件开发，感谢ianva！


