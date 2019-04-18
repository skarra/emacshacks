;;; ~/.cust.emacs - Emacs startup file, Sriram Karra

;; Apr 2019: Desire to reboot my Emacs customisations. The idea is to
;; let go of 20 years of Emacs customizations and start afresh and
;; only aiming to support Emacs 26 onwards. My editing needs are more
;; modest, and Emacs can do so much more these days. So let'see what a
;; fresh start can do.

;;; Generic setup code -- very basic and important routines.

;; Define certain macros that we can use to differentiate between the
;; different Emacs versions/flavours

(setq debug-on-error t)

;; Disable tool-bar and menu-bar to reclaim real estate
(menu-bar-mode -1)
(when window-system
  (tool-bar-mode -1))

(defun add-file-list-to-list (list-sym names &optional expand-file-p)
  "Adds a list  of names to given list.  The first  argument should be a
list, as a symbol, to which will  be added all the names in the `names',
one at  a time using `add-to-list'.   If the optional  third argument is
non-nil, then the names  are all piped through `expand-file-name' before
being added."
  (mapcar (lambda (a)
	    (when (file-exists-p a)
	      (add-to-list list-sym (or (and expand-file-p
					     (expand-file-name a)
					     a)))))
	  names))

(add-file-list-to-list 'load-path
		       '("~/elisp"
			 "~/elisp/lisp/"
			 )
 			t)

(add-file-list-to-list 'Info-default-directory-list
		       '("~/elisp/info/"
			 "~/info")
		       t)

(when (require 'ibuffer nil t)
  (global-set-key [?\C-x ?\C-b] 'ibuffer)
  (setq ibuffer-formats
	'((mark modified read-only " "
		(name 16 16) " " (size 6 -1 :right)
		" " (mode 16 16) " " filename)
	  (mark modified read-only " " (name 30 30)
		" " filename)
	  (mark modified read-only " "
		(name 16 -1) " " (size 6 -1 :right)
		" " (mode 16 16) " " filename))))

(when (require 'ido nil t)
  (ido-mode 1)
  (setq ido-everywhere t)
  (setq ido-enable-flex-matching t))

;; enable column number mode.  now, we have the coloumn number displayed
;; in the mode line.  I can't believe it that this is not the default
(column-number-mode t)

;; display the  time and  mail flag  in the mode  line.  All  this stuff
;; takes up  a lot of space  in the mode line.   So much so  that in the
;; default setup of  the modeline format, the line  numbers are not even
;; visible!  Ofcourse most of the blame for this nonsense should fall on
;; the display of the mode names.
(add-hook 'display-time-hook
	  (lambda ()
	    (setq display-time-24hr-format t)
	    (setq display-time-day-and-date t)))
(display-time)

;; Some global key definitions
(global-set-key "\M-g"			'goto-line)
