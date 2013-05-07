#!/bin/sh
rsync -arvuz www/ coxlab@coxlab.org:~/webapps/mcb80x/map --exclude '.git' --exclude 'scripts'
