#!/bin/zsh -fe
cd $0:a:h
wheezy.template fonts.conf.wz =(yaml-get -p . vars.yml) >fonts.conf
