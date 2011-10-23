;;; ff.el -- Intelligently set major mode for new buffers

;; Copyright (C) 2002 Sriram Karra <karra@cs.utah.edu>
;; Author: Sriram Karra <karra@cs.utah.edu>

;;; *** L I C E N S E ***

;; Distributed under the GPL (version 2 only)

;;; Notes:

;; Many times, when a new file is opened, the correct editing mode
;; cannot be selected.  Examples of this are text files that need
;; Outline mode, shell scripts that do not have the .sh suffix, perl
;; scripts that do not have the .pl suffix etc.  In these cases, the
;; first line that is typed, typically is something that specifies the
;; right mode (soemthing like #!/bin/bash or -*- Outline -*- or
;; whatever).  So, by the time the user types RET for the first time in
;; an originally empty buffer, we have enough info to set the right
;; mode.  This saves one from typing in the right command to switch the
;; mode manually (even if it is something as simple as M-x normal-mode
;; RET :)

;; So, the deal is we add  something to find-file hooks that watches for
;; the first  newline.  (normal-mode) is  then invoked and  the original
;; keybinding for RET restored.

;;; Installation

;; Put this file somewhere in your load-path and do a
;; (load-library "ff.el") somewhere in your ~/.emacs

;;; Code

(defvar ff-saved-enable-local-variables nil)

(defun ff-h ()
  "This function is intendend to be put into find-file-hook or some such.
This works very closely with."

  (when (= (buffer-size) 0)
    (message "Inside ff-h")    
    (setq ff-saved-enable-local-variable enable-local-variables)
    (setq enable-local-variables t)

    (substitute-key-definition 'newline
			       'ff-c (current-global-map))))
    
(defun ff-c ()
  (interactive)
  (normal-mode)
  (newline)
  (setq enable-local-variables ff-saved-enable-local-variable)

    (substitute-key-definition 'ff-c
			       'newline (current-global-map)))

(add-hook 'find-file-hooks 'ff-h)

;;; ff.el ends here
