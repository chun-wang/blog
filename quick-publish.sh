#!/bin/bash

# commit to blog
git add --all .
git commit -m"quick publish"
git push

# deploy web
hexo g -d
