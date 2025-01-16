USING:
  accessors
  arrays
  assocs
  editors
  io
  kernel
  listener
  memory
  namespaces
  prettyprint.config
  sequences
  ui.commands
  ui.gadgets.editors
  ui.gadgets.worlds
  ui.gestures
!  ui.theme.base16
  ui.theme.switching
  ui.tools.listener.completion
  ui.tools.theme
  vectors
  vocabs
  words ;

! -- Simple options --
EDITOR: editors.sublime
2 tab-size set

! -- Make it legible --
dark-mode
! "ayu-dark" base16-theme-name set-global base16-mode
32 set-tools-font-size

! -- Cell-style horizontal Data Stack display --
! Credit: John Benediktsson (thanks!)
IN: prettyprint
: datastack. ( seq -- )
  [
    "\n! " write
    1array
    H{
      { has-limits?            t }
      { length-limit           5 }
      { line-limit            12 }
      { margin                24 }
      { pprint-string-cells?   t }
      { tab-size               2 }
    } [ simple-table. ] with-variables
  ] unless-empty ;

! -- Set keys --
! Credit: John Benediktsson (thanks!)
IN: ui.tools.listener

! Up and Down to navigate history:
interactor "completion" {
  { T{ key-down f f "UP"   } recall-previous }
  { T{ key-down f f "DOWN" } recall-next     }
} update-command-map

! Ctrl+l to clear the output:
editor commands "selection" of [
  >vector
  T{ key-down f { C+ } "l" } over delete-at
  >array
] change-commands drop editor update-gestures
listener-gadget "custom" f {
  { T{ key-down f { C+ } "l" } clear-output }
} define-command-map

! Make Shift+ also work for copy/paste/cut:
world "gestures" word-prop H{
  {
    T{ key-down { mods { C+ } } { sym "C" } }
    [ \ copy-action send-action ]
  }
  {
    T{ key-down { mods { C+ } } { sym "V" } }
    [ \ paste-action send-action ]
  }
  {
    T{ key-down { mods { C+ } } { sym "X" } }
    [ \ cut-action send-action ]
  }
} assoc-union! drop

! -- Load extra vocabs (and docs) --
interactive-vocabs [
  {
    "combinators.extras" "combinators.short-circuit.smart"
    "grouping.extras"
    "make" "math.combinatorics" "math.extras"
    "path-finding"
    "sequences.extras" "sets" "splitting" "splitting.extras"
  } [ require-all ] [ append ] bi
] change-global

! -- Short prompt --
IN: listener
: prompt ( -- str ) "🦖" ;

! -- Write to image --
save

! -- If anything goes wrong --
!
! $ cp factor.image.fresh factor.image
!
! -- or --
!
! $ factor -run=bootstrap.image && factor -i=boot.unix-x86.64.image && cp factor.image factor.image.fresh
