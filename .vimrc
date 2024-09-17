echo "syntax on" >> ~/.vimrc
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
