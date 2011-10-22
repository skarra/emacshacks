
;;;### (autoloads (frio-asm-mode) "frio-asm" "frio-asm.el" (15545
;;;;;;  31338))
;;; Generated autoloads from frio-asm.el

(autoload (quote frio-asm-mode) "frio-asm" "\
Major mode for editing Frio assembler code.
Features a private abbrev table and the following bindings:

\\[frio-asm-colon]	outdent a preceding label, tab to next tab stop.
\\[tab-to-tab-stop]	tab to next tab stop.
\\[frio-asm-newline]	newline, then tab to next tab stop.
\\[frio-asm-comment]	smart placement of assembler comments.

The characters used for making comments is set by the variable
`frio-asm-comment-start' (which defaults to \"//\").

Alternatively, you may set this variable in
`frio-asm-mode-set-comment-hook', which is called near the beginning of
mode initialization.

Turning on frio-asm mode runs the hook `frio-asm-mode-hook' at the end of
initialization.

Special commands:
\\{frio-asm-mode-map}
" t nil)

;;;***

;;;### (autoloads (insert-random-lost select-lost) "lost" "lost.el"
;;;;;;  (15545 29579))
;;; Generated autoloads from lost.el

(autoload (quote select-lost) "lost" "\
Select a LOST document from a list of all available LOSTs.
A new buffer is created and the subject lines are displayed.  The buffer
is in the \"LOST-mode\".  Pressing \"RET\" will insert the entire LOST
file corresponding to the current line at point in the buffer from where
you invoked `select-lost'." t nil)

(autoload (quote insert-random-lost) "lost" "\
Inserts a random LOST file from `lost-dir' at point (i.e. cursor)." t nil)

;;;***

;;;### (autoloads (random-man) "random-man" "random-man.el" (15545
;;;;;;  29361))
;;; Generated autoloads from random-man.el

(autoload (quote random-man) "random-man" "\
Generate a Unix man page at random.
The $MANPATH environment variable is consulted for this purpose.  If it is
invalid, then it will terminate with an error.  Termination might occur
even if one component of your $MANPATH is invalid.  The function `man' from
man.el, which is distributed with GNU Emacs, is used to do the atcual
displaying." t nil)

;;;***

