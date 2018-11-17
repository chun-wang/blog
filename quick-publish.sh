#!/bin/bash

# update git
git pull
git submodule foreach git pull

# update theme config
cp _config_maupassant.yml themes/maupassant/_config.yml

# files changed
git status

# commit to blog
git add --all .
git commit -m"quick publish"
git push

# deploy web
hexo clean

# copy CNAME
mkdir public
cp CNAME public/

hexo g -d
