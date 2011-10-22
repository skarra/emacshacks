;;; Sample .emacs: This file is read at startup -*- emacs-lisp -*-

;; $Id: sample.emacs,v 1.1 2003/03/10 12:17:34 karra Exp $

;;	"All user customisations go into ~/.customs.emacs"
;;			-- Old Indian saying.

;; Version      : 0.0.3

;; Author	: Sriram Karra <sriramkarra@yahoo.com>
;; Created	: Tue Oct 23 2001 11:25

;;; NOTES:

;; Known to work with Xemacs 21.1 and GNU Emacs 20.7.1 and GNU Emacs
;; 21.1 

;; Avoid modifying this file.  If you want to add something, put
;; them in ~/.customs.emacs.  That file will be read in at the end so
;; your customisations will take precedence.  This will enable the
;; system administrator to install more useful ~/.emacs and you will not
;; lose your changes.

;;; General Customization

;; When files are opened in Emacs, it is possible to evaluate arbitrary
;; Lisp expressions; This is a potential security hazard.  Do NOT change
;; this unless you know exactly what you are letting yourself in for.  [
;; The default value for this variable is 'maybe ]
(setq enable-local-eval nil)

;; By default when you mark a region (by pressing the left mouse button
;; and dragging the mouse), the region is not highlighted.  Let us
;; enable this and prevent region-based commands from running when the
;; mark isn't active.
(pending-delete-mode t)
(setq transient-mark-mode t)

;; By default, when you press C-x C-c, it will quitely quit.  The
;; following code will force emacs to ask for confirmation.
(setq kill-emacs-query-functions
  (list (lambda ()
	  (ding)
	  (y-or-n-p "Really quit? "))))

;; Enable line and column number modes.
(line-number-mode t)
(column-number-mode t)

;; If you want the time to be displayed on the modeline, uncomment the
;; following lines.
(add-hook 'display-time-hook
	  (lambda ()
	    (setq display-time-24hr-format t)
	    (setq display-time-day-and-date t)))
(display-time)

;; Put all the results of customisations from inside emacs [ i.e. the
;; results of M-x customize RET ] at the end of .customs.emacs and not
;; .emacs which is the default
(when (file-exists-p "~/.customs.emacs")
  (setq custom-file "~/.customs.emacs"))

;; Make available a list of recently opened files.  This list can be
;; accessed through the "Files" menu.  NOTE: recentf is a recent
;; addition to Emacs.  So, do not be surprised if you do not see the
;; promised menu item in your emacs session.
(when (fboundp 'recentf-mode)
  (recentf-mode t))

;; By default, scrolling does not halt when the end of file is reached.
;; Let us disable this.  And setup a few other things.
(setq next-line-add-newlines nil
      default-major-mode 'text-mode
      require-final-newline t)

;;; Key Bindings

;; Emacs has certain really painful default key bindings.  Like pressing
;; "end" will take  you to the end of the buffer and NOT the end of the
;; line.  This "anomolous" behaviour pisses a lot of people off.  Here
;; we try to address a few of the issues.  We are setting some "global
;; key-bindings" i.e., key-bindings that will be valid no matter what
;; kind of buffer you are editing.

(global-set-key "\M-g"			'goto-line)
(global-set-key [(f1)]			'info)
(global-set-key [(f2)]			'save-buffer)
(global-set-key [(home)]		'beginning-of-line)
(global-set-key [(end)]			'end-of-line)
(global-set-key [(control home)]	'beginning-of-buffer)
(global-set-key [(control end)]		'end-of-buffer)
(global-set-key [(control delete)]	'delete-char)

;;; Colors and stuff.

;; `font-lock' is the package that deals with syntax specific coloring
;; (like coloring comments in a C program red, strings green, etc.).
;; Let's turn it on.
(setq font-lock-maximum-decoration t)
(unless (featurep 'xemacs)
  (global-font-lock-mode t))
(turn-on-font-lock)

;; Uncomment the following line if you find the regular font locking a
;; little slow while editing large files.  Look at the documentation for
;; the variable for more information.
;(setq font-lock-support-mode 'lazy-lock-mode)

;; The default colors in Emacs, well, leave a lot to be desired.  This
;; function changes these defaults, and brings some color into our
;; lives.  If you want to revert to the Emacs defaults (because you are
;; running on a mono-chrome display or something), commenting out the
;; call to this function below would suffice.  If you want to experiment
;; with other color settings, you can find the list of available colors
;; in the file /usr/share/emacs/20.7/etc/rgb.txt or
;; /usr/X11R6/lib/X11/rgb.txt

(defun setup-colors ()  

  (unless (featurep 'xemacs)
    (set-cursor-color "red")
    (set-mouse-color "brown"))

  ;; set colors
  (when window-system
    (set-face-foreground 'default          "black")
    (set-face-background 'default          "beige"))

  (set-face-background 'modeline         "gray")
  (set-face-foreground 'modeline         "red")

  (if (featurep 'xemacs)
      (prog2
	  (set-face-foreground 'zmacs-region	"ForestGreen")
	  (set-face-background 'zmacs-region	"white"))
    (prog2
	(set-face-foreground 'region           "ForestGreen")
	(set-face-background 'region           "white")))
  
  ;; see m-x list-faces-display too

  (set-face-foreground 'italic "darkgoldenrod")
  (set-face-foreground 'bold "red")
  
  (set-face-foreground font-lock-comment-face "red")
  (set-face-foreground font-lock-string-face "cornsilk1")
  (set-face-foreground font-lock-function-name-face "brown")
  (set-face-foreground font-lock-keyword-face "mediumturquoise")
  (set-face-foreground font-lock-type-face "blue4")
  (set-face-foreground font-lock-variable-name-face "firebrick")
  (set-face-foreground font-lock-reference-face "red3")
  (set-face-foreground font-lock-string-face "green4")
  (set-face-foreground font-lock-variable-name-face "orangered")
      
;  (make-face-unitalic font-lock-string-face nil)
;  (set-face-underline-p font-lock-string-face nil)
;  (make-face-italic font-lock-comment-face nil)

  (unless (featurep 'xemacs)
    (set-face-foreground font-lock-warning-face "Red")	
    (set-face-foreground font-lock-constant-face "deepskyblue")
    (set-face-foreground font-lock-builtin-face "Orchid")))

;; Finally install the colors - if you do not want the above colors to
;; take effect, just uncomment this line.
(setup-colors)

;;; Major mode stuff

;; We will setup this hook function to be run when any program is opened
;; for editing.
(defun general-prog-mode-hook ()
  "Bind Return to `newline-and-indent' in the local keymap."

  ;; By default, pressing ENTER only bring the cursor to the next line.
  ;; It does not indent the cursor to the right place...  If you have
  ;; edited any program under vanilla Emacs, you would know exactly I am
  ;; talking about...  The following will do what most users normally
  ;; expect.  Incidentally, even in vanilla Emacs, you had the exactly
  ;; same functionality bound to the C-j key sequence.
  (local-set-key "\C-m" 'newline-and-indent)

   ;; We also want to enable auto-fill in the various programming
   ;; languages.  Auto-fill is the Emacs lingo for the feature that
  ;; wraps the lines as you type them, after the lines reach a certain
  ;; number of characters.  fill-column is the variable that dictates
  ;; when this wrapping should happen, and the first command tells Emacs
  ;; that such wrapping should occur at all.
  (turn-on-auto-fill)
  (setq fill-column 72)

  ;; It is very convenient to have a key binding to comment out a
  ;; region.  We hereby bind the command to C-c C-c.  Emacs "knows" the
  ;; comment syntax for most programming languages, and pressing C-c C-c
  ;; in different language programs would have the "right" effect ;-)
  (local-set-key [?\C-c ?\C-c] 'comment-region)

  ;; Hm. Oh well...  Let this one just be... :-)
  (when (fboundp 'filladapt-mode)
    (filladapt-mode t)))

;; Tell Emacs to use the function above in certain editing modes.
(add-hook 'lisp-mode-hook             (function general-prog-mode-hook))
(add-hook 'emacs-lisp-mode-hook       (function general-prog-mode-hook))
(add-hook 'lisp-interaction-mode-hook (function general-prog-mode-hook))
(add-hook 'scheme-mode-hook           (function general-prog-mode-hook))
(add-hook 'c-mode-hook                (function general-prog-mode-hook))
(add-hook 'c++-mode-hook              (function general-prog-mode-hook))
(add-hook 'perl-mode-hook             (function general-prog-mode-hook))
(add-hook 'cperl-mode-hook            (function general-prog-mode-hook))

;; When the first line of a file has somehting lie
;; #!/usr/local/bin/perl or something, Emacs automatically goes into a
;; certain mode whichit identifies by looking up
;; interpreter-mode-alist.  the default for perl is perl-mode. 
(setq interpreter-mode-alist
      (append '(("perl"    . cperl-mode))
	      interpreter-mode-alist))

;; The default "style" for editing C/C++/Java files is set according to
;; the GNU coding conventions.  We personally prefer the K&R style.
;; There are many differences, the main one being GNU stipulates the use
;; of 2 spaces for indentation levels, where K&R style uses 5.  If you
;; want to use it, uncomment out the following lines.

(defun my-c-mode-common-hook ()
  "Custom setup meant for all CC Modes."
  ;; uncomment out the following line if you want "backspace" to delete
  ;; everything till the previous non-whitespace character.  
  ;;  (c-toggle-hungry-state 1)
  (c-set-style "k&r")
  (setq tab-width 8)
  (setq indent-tabs-mode t))

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)


;; By default when typing normal text, Emacs will not insert newlines
;; when your margin limit is reached.  The command "turn-on-auto-fill"
;; will do this.  

;; Text-based modes (including mail, TeX, and LaTeX modes) are auto-filled.
(add-hook 'text-mode-hook 'turn-on-auto-fill)


;; This gives the form of the default compilation command for C++, C, and
;; Fortran programs.  Specifying the "-lm" option for C and C++  eliminates a
;; lot of potential confusion.

(defvar compile-guess-command-table
  '((c-mode       . "gcc -g %s -o %s -lm") ; Doesn't work for ".h" files.
    (c++-mode     . "g++ -g %s -o %s -lm") ; Doesn't work for ".h" files.
    (fortran-mode . "f77 -C %s -o %s")
    )
  "*Association list of major modes to compilation command descriptions.
Used by the function `compile-guess-command'.  For each major mode, the
compilation command may be described by either:

  + A string, which is used as a format string.  The format string must
    accept two arguments: the simple (non-directory) name of the file to be
    compiled, and the name of the program to be produced.

  + A function.  In this case, the function is called with the two
    arguments described above and must return the compilation command.")


;; This code guesses the right compilation command when Emacs is asked
;; to compile the contents of a buffer.  It bases this guess upon the
;; filename extension of the file in the buffer.

(defun compile-guess-command ()

  (let ((command-for-mode (cdr (assq major-mode
                                     compile-guess-command-table))))
    (if (and command-for-mode
             (stringp buffer-file-name))
        (let* ((file-name (file-name-nondirectory buffer-file-name))
               (file-name-sans-suffix (if (and (string-match "\\.[^.]*\\'"
                                                             file-name)
                                               (> (match-beginning 0) 0))
                                          (substring file-name
                                                     0 (match-beginning 0))
                                        nil)))
          (if file-name-sans-suffix
              (progn
                (make-local-variable 'compile-command)
                (setq compile-command
                      (if (stringp command-for-mode)
                          ;; Optimize the common case.
                          (format command-for-mode
                                  file-name file-name-sans-suffix)
                        (funcall command-for-mode
                                 file-name file-name-sans-suffix)))
                compile-command)
            nil))
      nil)))

;; Add the appropriate mode hooks.
(add-hook 'c-mode-hook       (function compile-guess-command))
(add-hook 'c++-mode-hook     (function compile-guess-command))
(add-hook 'fortran-mode-hook (function compile-guess-command))

;; This creates and adds a "Compile" menu to the compiled language modes.
(defvar compile-menu nil
  "The \"Compile\" menu keymap.")

(defvar check-option-modes nil
  "The list of major modes in which the \"Check\" option in the \"Compile\"
menu should be used.")

(defvar compile-menu-modes nil
  "The list of major modes in which the \"Compile\" menu has been installed.
This list used by the function `add-compile-menu-to-mode', which is called
by various major mode hooks.")


;; Create the "Compile" menu.
(if compile-menu
    nil
  (setq compile-menu (make-sparse-keymap "Compile"))
  ;; Define the menu from the bottom up.
  (define-key compile-menu [first-error] '("    First Compilation Error" .
                                           first-compilation-error))
  (define-key compile-menu [prev-error]  '("    Previous Compilation Error" .
                                           previous-compilation-error))
  (define-key compile-menu [next-error]  '("    Next Compilation Error" .
                                           next-error))
  (define-key compile-menu [goto-line]   '("    Line Number..." .
                                           goto-line))

  (define-key compile-menu [goto]        '("Goto:" . nil))
  ;;
  (define-key compile-menu [indent-region] '("Indent Selection" .
                                             indent-region))

  (define-key compile-menu [make]         '("Make..." . make))

  (define-key compile-menu [check-file]   '("Check This File..." . 
                                            check-file))

  (define-key compile-menu [compile]     '("Compile This File..." . compile))
  )

;; Enable check-file only in Fortran mode buffers
(put 'check-file 'menu-enable '(eq major-mode 'fortran-mode))

;; Here are the new commands that are invoked by the "Compile" menu.
(defun previous-compilation-error ()
  "Visit previous compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
  (interactive)
  (next-error -1))

(defun first-compilation-error ()
  "Visit the first compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
  (interactive)
  (next-error '(4)))

(defvar check-history nil)

(defun check-file ()
  "Run ftnchek on the file contained in the current buffer"
  (interactive)
  (let* ((file-name (file-name-nondirectory buffer-file-name))
         (check-command (read-from-minibuffer
                         "Check command: "
                         (format "ftnchek %s" file-name) nil nil
                         '(check-history . 1))))
    (save-some-buffers nil nil)
    (compile-internal check-command "Can't find next/previous error"
                      "Checking" nil nil nil)))

(defun make ()
  "Run make in the directory of the file contained in the current buffer"
  (interactive)
  (save-some-buffers nil nil)
  (compile-internal (read-from-minibuffer "Make command: " "make ")
                    "Can't find next/previous error" "Make"
                    nil nil nil))


;; Define a function to be called by the compiled language mode hooks.
(defun add-compile-menu-to-mode ()
  "If the current major mode doesn't already have access to the \"Compile\"
menu, add it to the menu bar."
  (if (memq major-mode compile-menu-modes)
      nil
    (local-set-key [menu-bar compile] (cons "Compile" compile-menu))
    (setq compile-menu-modes (cons major-mode compile-menu-modes))
    ))


;; And finally, make sure that the "Compile" menu is available in C, C++, and
;; Fortran modes.
(add-hook 'c-mode-hook       (function add-compile-menu-to-mode))
(add-hook 'c++-c-mode-hook   (function add-compile-menu-to-mode))
(add-hook 'c++-mode-hook     (function add-compile-menu-to-mode))
(add-hook 'fortran-mode-hook (function add-compile-menu-to-mode))


;;; Load up libraries

(add-to-list 'load-path "~/elisp")
(require 'ibuffer)
(require 'boxquote)
(require 'scroll-in-place)

;;; Wind-up

;; Finally load any user customizations.  If for some reason you do not
;; want to load an existing .customs.emacs file, set the environment
;; variable NO_CUSTOMS to any value, like "export NO_CUSTOMS=t" on the
;; bash prompt

(unless (getenv "NO_CUSTOMS")
  (if (file-exists-p "~/.customs.emacs.elc")
      (load "~/.customs.emacs.elc" t t)
    (if (file-exists-p "~/.customs.emacs")
	(load "~/.customs.emacs" t t))))
