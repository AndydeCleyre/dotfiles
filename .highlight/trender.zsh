#!/bin/zsh -fe
cd $0:a:h
wheezy.template filetypes.conf.wz =(nt2json vars.nt) >filetypes.conf
