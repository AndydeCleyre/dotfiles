USING:
  accessors arrays assocs
  combinators.extras
  editors
  io
  kernel
  memory
  namespaces
  prettyprint.config
  sequences
  ui.commands ui.gadgets.editors ui.gestures ui.theme.switching ui.tools.listener.completion
  vectors vocabs.loader ;

! -- Simple options --
EDITOR: editors.sublime
2 tab-size set

! -- Make it legible --
dark-mode
IN: fonts
CONSTANT: default-font-size 32
"help.stylesheet" reload

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
! TODO: remove update-command-map definition when Factor > 0.99
: update-command-map ( class group pairs -- )
  pick
  [ commands ]
  [ of ]
  [ '[ _ assoc-union ] change-commands drop ]
  [ update-gestures ]
  quad* ;
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

! -- Load extra vocabs (and docs) --
IN: scratchpad
USING:
  combinators.extras combinators.short-circuit.smart
  math.combinatorics
  sequences.extras sets splitting splitting.extras ;

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
! $ factor -run=bootstrap.image
! $ factor -i=boot.unix-x86.64.image
! $ cp factor.image factor.image.fresh
