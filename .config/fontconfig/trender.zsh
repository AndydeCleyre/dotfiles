#!/bin/zsh -e
cd $0:P:h
wheezy.template fonts.conf.wz =(yaml-get -p . vars.yml) >fonts.conf
