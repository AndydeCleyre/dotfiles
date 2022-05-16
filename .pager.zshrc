export PAGER=less
export LESS=JRWXij.3

man () {  # <man-arg>...
  # standout -> standout
  # no-standout -> no-standout
  # underline -> green underline
  # no-underline -> no-color no-underline
  # bold -> bold
  # blink -> bold red
  # no-bold no-blink no-underline -> no-bold no-color no-underline

  LESS_TERMCAP_so=${(%):-%S} \
  LESS_TERMCAP_se=${(%):-%s} \
  LESS_TERMCAP_us=${(%):-%F{green}%U} \
  LESS_TERMCAP_ue=${(%):-%f%u} \
  LESS_TERMCAP_md=${(%):-%B} \
  LESS_TERMCAP_mb=${(%):-%B%F{red}} \
  LESS_TERMCAP_me=${(%):-%b%f%u} \
  =man $@
}

# b, bs, behead, ch, cols, d, gconfig, jqq, jqqq, l, lh, h, hs, highlight_themes, plain, rb, wh, what, z, zh, zh_complete

# less, but accept <doc>:<line-num> as last arg
l () {  # [<less-arg>...] [<doc>[:<line-num>] (or read stdin)]
  emulate -L zsh -o extendedglob

  local doc linenum
  doc=${@[-1]%:<->##}
  if [[ $doc != ${@[-1]} ]]  linenum=${@[-1]#${doc}:}

  LESS=${LESS:-JRWXij.3} less ${linenum:++${linenum}} ${linenum:+-N} ${@[1,-2]} ${doc}
}

() {
  emulate -L zsh
  local themes=(
    aiseered
    blacknblue
    bluegreen
    ekvoli
    navy
  )
  export HIGHLIGHT_OPTIONS="-O truecolor -s $themes[RANDOM % $#themes + 1] -t 4 --force --stdout"
}

hi () {  # [<highlight-arg>...]
  emulate -L zsh

  local themes=(
    aiseered
    blacknblue
    bluegreen
    ekvoli
    navy
  )

  highlight -O truecolor -s ${themes[RANDOM % $#themes + 1]} -t 4 --force --stdout $@
}

alias hs="h -s"  # <syntax> [<file> (or read stdin)]

h () {  # [-s <syntax>] [<doc>... (or read stdin)]
# TODO: support (in each case either translate and forward, or strip):
# highlight args: -m <num>, -l
# will need to update lh afterward
  emulate -L zsh -o extendedglob
  rehash

  # get syntax if first arg is md/rst file,
  # or pop if passed with -[Ss]
  local syntax syntax_idx=${@[(I)-[Ss]]}
  if (( syntax_idx )) {
    syntax=${@[$syntax_idx+1]}
    argv=($@[1,$syntax_idx-1] $@[$syntax_idx+2,-1])
  } else {
    case $1 {
      *(#i).rst)  syntax=rst  ;;
      *(#i).md)   syntax=md   ;;
    }
  }

  # use special highlighters if present, for md/rst/diff
  local hi
  case $syntax {
    md)
      for hi ( rich mdcat glow ) {
        if (( $+commands[$hi] )) {

          case $hi {
            rich)
              local r_args=(--force-terminal --no-wrap -W $(( COLUMNS-4 )) --markdown)
              if [[ ! -t 0  ]] {
                rich $r_args -
              } else {
                for 1 { rich $r_args $1 }
              }
              return
            ;;

            # ensure it passes style though pipes to a pager:
            glow)   argv=(-s dark $@)     ;;

            # do not fetch remote images:
            mdcat)  argv=(--local $@)     ;;
          }
          
          $hi $@
          return
        }
      }
    ;;
    rst)
      if (( $+commands[rich] )) {
        local r_args=(--force-terminal --no-wrap -W $(( COLUMNS-4 )) --rst)
        if [[ ! -t 0  ]] {
          rich $r_args -
        } else {
          for 1 { rich $r_args $1 }
        }
        return

      } elif (( $+commands[pandoc] )) {
        if (( $+commands[mdcat] )) || (( $+commands[glow] )) {

          for 1 { $0 -s md =(pandoc $1 --to commonmark) }
      	  return
        }
      }
    ;;
    diff)
      for hi ( riff delta diff-so-fancy colordiff ) {
        if (( $+commands[$hi] )) {

          # delta will use BAT_THEME
          BAT_THEME=${BAT_THEME:-ansi} \
          $hi $@
          return
        }
      }
    ;;
  }

  if (( $+commands[highlight] )) {
    local themes=(aiseered blacknblue bluegreen ekvoli navy)

    local h_args=(-O truecolor -s ${themes[RANDOM % $#themes + 1]} -t 4 --force --stdout $@)
    if [[ $syntax ]]  h_args+=(-S $syntax)

    # Empty input can yield unwanted newlines as output from highlight.
    # https://gitlab.com/saalen/highlight/-/issues/147
    # This can be avoided in highlight >= 3.56 with: --no-trailing-nl=empty-file
    # As a workaround for more version support,
    # we check stdin for non-emptiness before passing it along to highlight.

    if [[ ! -t 0 ]] {
      local content=$(<&0)
      if [[ $content ]]  highlight $h_args <<<$content
    } else {
      highlight $h_args
    }

  } elif (( $+commands[bat] )) {
    if [[ $syntax ]]  argv+=(-l $syntax)
    bat -p --paging never --color always $@
  } elif (( $+commands[batcat] )) {
    if [[ $syntax ]]  argv+=(-l $syntax)
    batcat -p --paging never --color always $@

  } elif (( $+commands[rich] )) {
    local r_args=(--force-terminal --no-wrap -W $(( COLUMNS-4 )))
    if [[ $syntax ]]  r_args+=(--lexer $syntax)

    if [[ ! -t 0  ]] {
      rich $r_args -
    } else {
      for 1 { rich $r_args $1 }
    }
  } else {
    cat $@
  }
}

export BAT_THEME=ansi
alias b="bat -p --pager never --color always"  # <file>
alias bs="b -l"   # <syntax> <file>; <cmd> | bs <syntax>

alias plain="sed 's/\x1b\[[0-9;]*m//g'"  # <cmd> | plain

lh () {  # [<doc>[:<line-num>]] [-s <syntax>] [<h-arg>...]
  emulate -L zsh -o extendedglob

  # syntax can be specified before doc as well
  local doc_idx=1 syntax_idx=${@[(I)-[Ss]]}
  if [[ $syntax_idx == 1 ]]  doc_idx=3

  # strip the optional :<line-num> from <doc>
  local doc=${@[$doc_idx]%:<->##}

  # extract <line_num> to pass to less
  local linenum
  if [[ $doc != ${@[$doc_idx]} ]]  linenum=${@[$doc_idx]#${doc}:}

  h ${doc} ${@[0,$doc_idx-1]} ${@[$doc_idx+1,-1]} | LESS=${LESS:-JRWXij.3} less ${linenum:++${linenum}} ${linenum:+-N}
}

alias z="h -S zsh"

alias jqq="jq -R -r '. as \$line | try fromjson catch \$line'"
alias jqqq="jq -R 'fromjson?'"

alias gconfig="h -S ini .git/config"

d () {  # <file1> <file2> [<delta-opt>...]
  emulate -L zsh
  rehash

  if (( $+commands[delta] )) {
    diff -u $1 $2 | delta $@[3,-1]
  } else {
    diff -u $1 $2 | h -S diff
  }
}

.zhelp () {  # (<zshrc>|<function>|<alias>)
  emulate -L zsh
  rehash

  # TODO: backport innovations from what (alias wh) and .zpy

  local pattern files=() funcname
  if [[ -f $1 ]] {
    pattern='^(alias|#|$|(\S+ \(\)))'
    files+=($1)
  } else {
    funcname=$1
    pattern='^(#[^\n]*\n)*^(alias '$funcname'=[^\n]+|'$funcname' ?\([^\n]*)'
    files+=(${ZDOTDIR:-~}/.*zshrc)
  }

  local cmd=()
  if (( $+commands[rg] )) {
    cmd+=(rg -UNI $pattern $files)
  } elif (( $+commands[pcre2grep] )) {
    cmd+=(pcre2grep -Mh $pattern $files)
  } elif (( $+commands[pcregrep] )) {
    cmd+=(pcregrep -Mh $pattern $files)
  } else {
    print -u2 'Not found: ripgrep, pcre2grep, or pcregrep'
    return 2
  }

  local failed
  # $cmd | se
  $cmd | uniq
  failed=${pipestatus:#0}

  if [[ $failed && $funcname ]] which $funcname
}
zh () {  # (<zshrc>|<function>|<alias>)
    .zhelp $@ | z
}

alias ch="choose --one-indexed"  # try

cols () {  # <range> [delimiter-regex='[[:blank:]]+'] [cut-args...]
    sed -E "s/${2:-[[:blank:]]+}/\t/g" | cut -f $1 ${@:3}

    # local txt=$(sed -E "s/${2:-[[:blank:]]+}/\t/g" | cut -f $1 ${@:3})
    # local numcols=$[$(head -n 1 <<< $txt | grep -o $'\t' | wc -l)+1]
    # local cells=(${(@s:$'\t':)txt})
    # print -raC $numcols $cells
    # print -rl $cells[1]
}
behead () {  # [head-count=1] [delimiter-regex='[[:blank:]]+']
    cols 1-${1:-1} "${2:-[[:blank:]]+}" --complement
}

alias rb="rainbow"

# TODO: probably move some of this parsing/transformation into .zhelp
# TODO: subcommand parsing
# TODO: generalize enough to apply to zpy...
zh_complete () {  # <funcname...>
  if (( $+functions[compdef] )) {
    for f ( $@ ) {
      _${f} () {
        _arguments '*:icon file:_files'
        _message -r "$(
          .zhelp ${0[2,-1]} \
          | sed -E 's/(.*) \(\) \{  # (.*)/%B\1%b \2/g' \
          | sed -E 's/^(#.*)/%F{blue}\1%f/g'
        )"
      }
      compdef _${f} ${f}
    }
  }
}
zh_complete zh cols behead bldr

highlight_themes () {  # <sample-file> [<highlight-options>]
  # take newline-delimited list of themes on stdin, or use all installed themes
  # resulting shortlist saved to reply
  emulate -L zsh
  # zmodload zsh/terminfo
  unset reply

  if [[ ! -r $1 ]] {
    print -rl -- \
      'USAGE: highlight_themes <sample-file> [<highlight-options>]' \
      'Shows the sample file rendered with each theme, one at a time, allowing you to save your favorites' \
      'Accepts a newline-delimited list of theme names on stdin, or uses all installed themes' '' \
      'EXAMPLES:' \
      '  highlight_themes pyproject.toml' \
      '  highlight_themes pyproject.toml <shortlist.txt' \
      '  highlight_themes ~/.zshrc -S zsh'
    return 1
  }

  local themes=() btheme
  if [[ -t 0 ]] {
    themes+=(/usr/share/highlight/themes/*.theme(:t:r))
    for btheme ( /usr/share/highlight/themes/base16/*.theme(:t:r) ) themes+=(base16/$btheme)
  } else {
    themes+=(${(f)"$(<&0)"})
  }

  local saved_themes=()
  for theme ( $themes ) {
    echoti clear
    highlight -s $theme -O truecolor -t 4 --force --stdout $@
    print -- That was $theme
    read -k '?Hit y to add to saved themes, or any key to continue '
    if [[ $REPLY:l == y ]] saved_themes+=($theme)
  }

  print -rlP -- '' '%U%BNew shortlist (saved in \$reply):%b%u' $saved_themes
  print -rlP -- '' '%BHint:%b print -l \$reply >>shortlist.txt'
  reply=($saved_themes)
}

# Print location and content of any function/alias,
# or display the manpage (or part of it).
what () {  # <funcname>
# TODO:
# - alias tracking?
  emulate -L zsh -o extendedglob
  rehash

  if [[ ! $1                 ]] { zh $0; return 1 }
  if [[ $1 =~ '^-(h|-help)$' ]] { zh $0; return   }

  local funcname=$1

  local pattern='^(#[^\n]*\n)*^('$funcname' ?\(([^\n]*|[\s\S]*?\n)\}$|alias '$funcname'=[^\n]+)'

  local cmd=() can_search=1
  if (( $+commands[rg] )) {
    cmd+=(rg -UNI)
  } elif (( $+commands[pcre2grep] )) {
    cmd+=(pcre2grep -Mh)
  } elif (( $+commands[pcregrep] )) {
    cmd+=(pcregrep -Mh)
  } else {
    print -u2 'Not found: ripgrep, pcre2grep, or pcregrep'
    can_search=
  }

  if (( $+functions[$funcname] )) {
    local src=${functions_source[$funcname]}
    [[ $src ]] || can_search=
    if [[ -t 1 ]] {
      whence -v $funcname
      if [[ $can_search ]] {
        $cmd $pattern $src | h -S zsh
        if ! [[ ${pipestatus:#0} ]] return
      }
      which -x 4 $funcname | h -S zsh
    } else {
      if [[ $can_search ]] {
        $cmd $pattern $src
        if ! [[ ${pipestatus:#0} ]] return
      }
      which -x 4 $funcname
    }
  } elif (( $+aliases[$funcname] )) {
    local alias_srcs=(~/.*.zshrc)
    if [[ $can_search ]] {
      if [[ -t 1 ]] {
        $cmd $pattern $alias_srcs | h -S zsh
        if ! [[ ${pipestatus:#0} ]] return
      } else {
        $cmd $pattern $alias_srcs
        if ! [[ ${pipestatus:#0} ]] return
      }
    }
    if [[ -t 1 ]] {
      whence -f $funcname | h -S zsh
    } else {
      whence -f $funcname
    }
  } else {
    run-help $funcname  # Better run-help enabled in .zsh.zshrc
    # TODO: wrap run-help with a func that adds .zhelp info? bound to esc,h
    which $funcname
  }
}

alias wh="what"

if (( $+functions[compdef] )) {
  _what () {
    _message -r "$(.zhelp ${0[2,-1]})"
    shift 1 words
    (( CURRENT-=1 ))
    _normal -P
  }
  compdef _what what
  # TODO: make a general func to generate these _normal ones,
  # in addition to improving .zhelp
}

rayso () {  # [-t <title>] [<doc> (or read stdin)]
  emulate -L zsh

  local title title_idx=${@[(I)-t]}
  if (( title_idx )) {
    title=${@[$title_idx+1]}
    argv=(${@[1,$title_idx-1]} ${@[$title_idx+2,-1]})
  } elif [[ ! -t 0 ]] {
    title=Terminal
  } elif [[ $1 ]] {
    title=$1:t
  }

  if [[ -t 0 && ! $1 ]] { zh $0; return 1 }

  local content
  if [[ $1 ]] {
    content=$(<$1 base64)
  } else {
    content=$(base64)
  }

  # https://github.com/raycast/script-commands/blob/master/commands/developer-utils/create-image-from-code.sh
  # Urlencode any + symbols in the base64 encoded string
  content=${content//+/%2B}

  firefox "https://ray.so/?colors=breeze&background=false&darkMode=true&padding=16&title=$title&code=$content"
}
