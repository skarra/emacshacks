;;; ~/.emacs -- The file that is read in at Emacs startup time.

;; There really isn't much here because... Well, it is a long story ;-)
;; Get the whole story in ~/.customs.emacs

;; NOTE: For the following ~/ syntax to work under Windows, you should
;; have set the HOME environment variable to the right path.

(setq whereami 'hackerrank)

;; For some reason tool-bar-mode is not defined on the default Emacs
;; 22.1 installed with Lion. Let's sort of ignore it for now.
(unless (eq whereami 'hackerrank)
  (menu-bar-mode -1))

(unless (and (eq whereami 'hackerrank)
	     (not (boundp 'aquamacs-version)))
  (tool-bar-mode -1))

(require 'cl)
(if (file-exists-p "~/.customs.emacs.elc")
    (load-file "~/.customs.emacs.elc")
  (load-file "~/.customs.emacs"))

(put 'eval-expression 'disabled nil)
