;;; frio-asm.el --- mode for editing Frio assembler code
;;
;; Author:	Sriram Karra <sriram.karra@intel.com>
;; Version:	0.1
;; Created:	May 31, 2001

;;; $Id: frio-asm.el,v 1.2 2001/06/06 20:21:21 skarra Exp $

;;; Installation:

;; Put this file somewhere in your load-path, and put the following line in
;; your .emacs:
;;
;; (autoload 'frio-asm-mode "frio-asm" "Mode for Frio assembler files")
;;
;; Then, when editing a frio assembly file, you can enter frio-asm-mode by
;; doing M-x frio-asm-mode RET
;;
;; Alternately, you can put the following in your .emacs:
;;
;; (setq auto-mode-alist(append '((\\.s$".frio-asm-mode)) auto-mode-alist))
;;
;; the above will make frio-asm-mode the default mode for all assembler
;; source files with a .s extension.

;;; Commentary:

;; This is a major mode for editing frio assembly files written by Sriram
;; Karra <sriram.karra@intel.com>.  This is based, to a _very_ large extent
;; on the asm-mode.el that ships with Emacs and written by Eric S. Raymond
;; <esr@snark.thyrsus.com>
;;
;; There are a number of reasons I had to generate a whole new version
;; Frio assembly's comment syntax is the same as C/C++ comment syntax.  The
;; original asm-mode quite comfortably assumed that assembler comments
;; would always start with single characters.  Well, this has been the
;; first assembler syntax that does not satisfy this assumption.  Frio
;; uses, as noted above, C/C++ style comments.  So, this breaks a lot of
;; things.
;;
;; The original asm-mode has a nice concept of "multi-level" comments.
;; Basically, it is the same thing as in Lisp, ';', ';;', and ';;;' type
;; comments are distinguished and indented differently.  Well, with the
;; comment start for Frio assembly begin "//", it did not quite make sense
;; to do the above concatentation.  This had to be fixed.

;; This mode is based on text mode.  It defines a private abbrev table that
;; can be used to save abbrevs for assembler mnemonics.  It binds just five
;; keys:
;;
;;	TAB		tab to next tab stop
;;	:		outdent preceding label, tab to tab stop
;;	C-[	place or move comment
;;			asm-comment-char specifies which character this is;
;;			you can use a different character in different
;;			Asm mode buffers.
;;	C-j, C-m	newline and tab to tab stop
;;	C-c C-s		frio-asm-insert-hex-str
;;
;; Code is indented to the first tab stop level.

;; This mode runs two hooks:
;;   1) An asm-mode-set-comment-hook before the part of the initialization
;; depending on asm-comment-char, and
;;   2) an asm-mode-hook at the end of initialization.

;;; TODO:

;; * The default binding for frio-asm-comment somehow goes to , we want
;;   it to be C-;... they both seem to get to the same value in some
;;   cases.... figure this thing out


;;; Code:

(defgroup frio-asm nil
  "Mode for editing assembler code."
  :group 'languages)

(defcustom frio-asm-comment-start "//"
  "*The comment-start characters assumed by frio-asm mode.
Note that the corresponding variable in asm-mode, asm-comment-char is a
single character."
  :type 'string
  :group 'asm)

(defvar frio-asm-mode-syntax-table nil
  "Syntax table used while in frio-asm mode.")

(defvar frio-asm-mode-abbrev-table nil
  "Abbrev table used while in frio-asm mode.")
(define-abbrev-table 'frio-asm-mode-abbrev-table ())

(defvar frio-asm-mode-map nil
  "Keymap for Asm mode.")

(if frio-asm-mode-map
    nil
  (setq frio-asm-mode-map (make-sparse-keymap))
  ;; Note that the comment character isn't set up until frio-asm-mode is
  ;; called.
  (define-key frio-asm-mode-map ":"	'frio-asm-colon)
  (define-key frio-asm-mode-map "\C-c;" 'comment-region)
  (define-key frio-asm-mode-map "\C-i"	'tab-to-tab-stop)
  (define-key frio-asm-mode-map "\C-j"	'frio-asm-newline)
  (define-key frio-asm-mode-map "\C-m"	'frio-asm-newline)
  (define-key frio-asm-mode-map "\C-c\C-s" 'frio-asm-insert-hex-str)
  )

(defconst frio-asm-font-lock-keywords
 '(("^\\(\\(\\sw\\|\\s_\\)+\\)\\>:?[ \t]*\\(\\sw+\\)?"
    (1 font-lock-function-name-face) (3 font-lock-keyword-face nil t))
   ("^\\s +\\(\\(\\sw\\|\\s_\\)+\\)" 1 font-lock-keyword-face))
 "Additional expressions to highlight in Assembler mode.")

(defvar frio-asm-code-level-empty-comment-pattern nil)
(defvar frio-asm-flush-left-empty-comment-pattern nil)
(defvar frio-asm-inline-empty-comment-pattern nil)

;;;###autoload
(defun frio-asm-mode ()
  "Major mode for editing Frio assembler code.
Features a private abbrev table and the following bindings:

\\[frio-asm-colon]\toutdent a preceding label, tab to next tab stop.
\\[tab-to-tab-stop]\ttab to next tab stop.
\\[frio-asm-newline]\tnewline, then tab to next tab stop.
\\[frio-asm-comment]\tsmart placement of assembler comments.

The characters used for making comments is set by the variable
`frio-asm-comment-start' (which defaults to \"//\").

Alternatively, you may set this variable in
`frio-asm-mode-set-comment-hook', which is called near the beginning of
mode initialization.

Turning on frio-asm mode runs the hook `frio-asm-mode-hook' at the end of
initialization.

Special commands:
\\{frio-asm-mode-map}
"
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "Frio-Asm")
  (setq major-mode 'frio-asm-mode)
  (setq local-abbrev-table frio-asm-mode-abbrev-table)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(frio-asm-font-lock-keywords))
  (make-local-variable 'frio-asm-mode-syntax-table)
  (setq frio-asm-mode-syntax-table (make-syntax-table))
  (set-syntax-table frio-asm-mode-syntax-table)

  (run-hooks 'frio-asm-mode-set-comment-hook)
  ;; Make our own local child of frio-asm-mode-map
  ;; so we can define our own comment syntax.
  (use-local-map (nconc (make-sparse-keymap) frio-asm-mode-map))
  (local-set-key "\C-;" 'frio-asm-comment)

  ;; And now, the most important portion -- the comment syntax.  The
  ;; following three lines are lifted verbatim from cc-langs.el, from the
  ;; portion that defines C{++}  syntax.  
  (modify-syntax-entry	?* ". 23"
			frio-asm-mode-syntax-table)
  (modify-syntax-entry	?/ ". 124b"
			frio-asm-mode-syntax-table)  
  (modify-syntax-entry	?\n
			 "> b" frio-asm-mode-syntax-table)

  ;; Some more comment syntax related cruft retained from asm-mode.
  (let ((cs (regexp-quote frio-asm-comment-start)))
    (make-local-variable 'comment-start)
    (setq comment-start (concat cs " "))
    (make-local-variable 'comment-start-skip)
    (setq comment-start-skip (concat cs "+[ \t]*"))
    (setq frio-asm-inline-empty-comment-pattern (concat "^.+" cs "+ *$"))
    (setq frio-asm-code-level-empty-comment-pattern
	  (concat "^[\t ]+" cs " *$"))
    (setq frio-asm-flush-left-empty-comment-pattern
	  (concat "^" cs " *$"))
    )
  (make-local-variable 'comment-end)
  (setq comment-end "")
  (make-local-variable 'comment-column)
  (setq comment-column 32)
  (setq fill-prefix "\t")
  (run-hooks 'frio-asm-mode-hook))

(defun frio-asm-colon ()
  "Insert a colon; if it follows a label, delete the label's indentation."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (looking-at "[ \t]+\\(\\sw\\|\\s_\\)+$")
	(delete-horizontal-space)))
  (insert ":")
  (tab-to-tab-stop)
  )

(defun frio-asm-newline ()
  "Insert LFD + fill-prefix, to bring us back to code-indent level."
  (interactive)
  (if (eolp) (delete-horizontal-space))
  (insert "\n")
  (tab-to-tab-stop)
  )

(defun frio-asm-line-matches (pattern &optional withcomment)
  (save-excursion
    (beginning-of-line)
    (looking-at pattern)))

(defun frio-asm-pop-comment-level ()
  ;; Delete an empty comment ending current line.  Then set up for a new one,
  ;; on the current line if it was all comment, otherwise above it
  (end-of-line)
  (delete-horizontal-space)
  (while (= (preceding-char) (aref frio-asm-comment-start 0))
    (delete-backward-char 1))
  (delete-horizontal-space)
  (if (bolp)
      nil
    (beginning-of-line)
    (open-line 1))
  )

;; This function has been hastily patched.  There really aren't three
;; levels of comments here...  It would be really ludicrous to have
;; "//////" to begin a comment...  
(defun frio-asm-comment ()
  "Start a new comment.
The documentation that follows is from the original asm-mode.  You would do
well to ignore it, as I do.  It is around just in case we can come up with
a need for such \"multi-level\" comments for our frio assembly.  Also,
please refer to comments in frio-asm.el sources.

  Convert an empty comment to a `larger' kind, or start a new one.
These are the known comment classes:

   1 -- comment to the right of the code (at the comment-column)
   2 -- comment on its own line, indented like code
   3 -- comment on its own line, beginning at the left-most column.

Suggested usage:  while writing your code, trigger frio-asm-comment
repeatedly until you are satisfied with the kind of comment."
  (interactive)
  (cond

   ;; Blank line?  Then start comment at code indent level.
   ((frio-asm-line-matches "^[ \t]*$")
    (delete-horizontal-space)
    (tab-to-tab-stop)
    (insert comment-start))

   ;; Nonblank line with no comment chars in it?
   ;; Then start a comment at the current comment column
   ((frio-asm-line-matches (format "^[^%s\n]+$" frio-asm-comment-start))
    (indent-for-comment))

   ;; Flush-left comment present?  Just insert character.
   ((frio-asm-line-matches frio-asm-flush-left-empty-comment-pattern)
    (insert comment-start))

   ;; Empty code-level comment already present?
   ;; Then start flush-left comment, on line above if this one is nonempty. 
   ((frio-asm-line-matches frio-asm-code-level-empty-comment-pattern)
    (frio-asm-pop-comment-level)
    (insert comment-start))

   ;; Empty comment ends line?
   ;; Then make code-level comment, on line above if this one is nonempty. 
   ((frio-asm-line-matches frio-asm-inline-empty-comment-pattern)
    (frio-asm-pop-comment-level)
;;    (tab-to-tab-stop)
    (insert comment-start))

   ;; If all else fails, insert character
   (t
    (insert comment-start))

   )
  (end-of-line))

(defun frio-asm-string-to-hex-str (str)
  "convert string literal to series of comma separated hex byte values.
Useful when writing assembly programs from scratch.  `str' can be a string
or a list of characters.  Escape sequences are not handled yet.
i.e. \"\\n\" would be treated as two characters the \"\\\" and \"n\".
Might be fixed soon."

  (let ((out "")
	(inp (if (stringp str)
		 (append str nil)
	       str)))
    (when (car inp)
      (setq out (format "0x%x" (car inp)))
      (setq inp (cdr inp))

      (while (car inp)
	(setq out (concat out (format ", 0x%x" (car inp))))
	(setq inp (cdr inp))))

    out))

(defun frio-asm-insert-hex-str (str)
  "Interactive version of `xx'.
Accepts a string literal from the minibufer, converts the constituent
characters to byte representation and inserts resulting output at point.
The function `frio-asm-string-to-hex-str' is called to do the actual
conversion."
  
  (interactive "sEnter string literal: \n")
  (insert (xx str)))

(provide 'frio-asm)

;;; frio-asm.el ends here
