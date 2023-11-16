#!/bin/zsh -fe
cd $0:a:h
wheezy.template fonts.conf.wz =(nt2json vars.nt) >fonts.conf
