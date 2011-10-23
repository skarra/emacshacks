;;; rfc2445.el -- Support for the iCalendar stuff.

;;; Installation

;; Put the following in your ~/.emacs
;; (autoload 'ical-mode "rfc2445.el")
;; (add-to-list 'auto-mode-alist '("\\.ics$" . ical-mode))

;;;###autoload
(defvar ical-load-hook '()
  "List of functions run after the iCal package is loaded.")

;;; Some generic functions

(defun ical-fold-buffer (&optional buf)
  "Replace long lines with \"CRLF \" combination.
The RFC mandates that transported content lines should not be more than
70 characters long.  This function reduces the size of these long
lines."
  (interactive)

  (unless buf (setq buf (current-buffer)))

  (save-excursion
    (with-current-buffer buf
      (goto-char (point-min))
      (let (start finish)
	(while (progn
	       (beginning-of-line)
	       (setq start (point))
	       (end-of-line)
	       (setq finish (- (point) start))
	       (if (<= finish 70)
		   (forward-line)
		 (backward-char (- finish 68))
		 (insert "\r\n "))
	       
	       (not (looking-at "^$"))))))))
  
(defun ical-unfold-buffer (&optional buf)
  "Inverse of `ical-fold-buffer'."

  (interactive)

  (unless buf (setq buf (current-buffer)))

  (save-excursion
    (with-current-buffer buf
      (goto-char (point-min))
      (let ((str "\r\n "))
	(while (search-forward str nil t)
	  (replace-match ""))))))

(defun conforms-to-rfc (&optional buf)
  "Checks if `buf' conforms to the RFC specifications.
This function is very scratchy right now...  It just checks for most
critical things only."

  (unless buf (setq buf (current-buffer)))

  (with-current-buffer buf
    (if (or (not (prog2
		     (goto-char (point-min))
		     (looking-at "^begin:vcalendar.*$")))
	    (not (progn
		     (goto-char (point-min))
;;		     (beginning-of-line)
		     (re-search-forward "^end:vcalendar.*$" nil t)))
	    (not (prog2
		     (goto-char (point-min))
		     (re-search-forward "^prodid:" nil t)))
	    (not (prog2
		     (goto-char (point-min))
		     (re-search-forward "^version:" nil t))))
	nil
      t)))

;;; Setup the new major mode for editing ical files.

;;;###autload
(defvar ical-mode-hook '()
  "A list of functions to be run after a buffer is put in iCal mode.")

(defvar ical-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-c" 'ical-parse-buffer)
    (define-key map "\C-c\C-u" 'ical-unfold-buffer)
    (define-key map "\C-c\C-f" 'ical-fold-buffer)
    map)
  "Keymap for `ical-mode'")

(defvar ical-mode-syntax-table
  (let ((st (make-syntax-table)))
    st))

(defvar ical-font-lock-keywords
  '("^begin"
    "^end"
    "^prodid"
    "^dtstart"
    "^dtend"
    "^summary"
    "^version"
    ("vcalendar\\|vevent" . 
     font-lock-comment-face)))

;;;###autoload
(define-derived-mode ical-mode fundamental-mode "iCal"
  "A major mode for editing iCal objects"
  (set (make-local-variable 'font-lock-defaults)
       '(ical-font-lock-keywords nil t))
  (use-local-map ical-mode-map)
  (run-hooks 'ical-mode-hook))

(provide 'ical-mode)

;;; Parsing related funcs

(require 'semantic)

(defvar ical-bovine-table
`((bovine-toplevel
 ( icalobject
  ,(semantic-lambda
  (nth 0 vals)))
 ) ; end ical
 (icalobject
 ( symbol "\\bbegin\\b" punctuation ":" symbol "\\bvcalendar\\b" icalbody symbol "\\bend\\b" punctuation ":" symbol "\\bvcalendar\\b"
  ,(semantic-lambda
  (list t nil nil ( ` macchi) (nth 3 vals))))
 ) ; end icalobject
 (icalbody
 ( semantic-list
  ,(semantic-lambda
 
 (semantic-bovinate-from-nonterminal-full (car (nth 0 vals)) (cdr (nth 0 vals)) 'calprop)
 ))
 ) ; end icalbody
 (calprop
 ( symbol "\\bprodid\\b" punctuation ":" symbol
  ,(semantic-lambda
  (list '`prodid (nth 2 vals))))
 ( symbol "\\bversion\\b" punctuation ":" symbol
  ,(semantic-lambda
  (list '`version (nth 2 vals))))
 ()
 ) ; end calprop
 )
                                                          )

(defvar ical-keyword-table
  nil
  )

(defun ical-parse-buffer ()
  (interactive)
  (message "Parsing buffer...done."))

(defvar ical-flex-extensions
  `())

(defmacro ical-flex-defun (fun char-count sym)
  `(defun ,fun ()
     (let ((start (match-end 0)))
       (forward-char ,char-count)
       (cons ,sym (cons start (point))))))

(ical-flex-defun ical-flex-begin 5 begin)
(ical-flex-defun ical-flex-end 3 end)
(ical-flex-defun ical-flex-vcalendar 9 vcalendar)
(ical-flex-defun ical-flex-vevent 6 vevent)

(defun ical-semantic-setup ()
  "Set up a Makefile buffer for parsing with semantic."
  (setq semantic-flex-extensions ical-flex-extensions)
  ;; Code generated from rfc2445.bnf
  (setq semantic-toplevel-bovine-table ical-bovine-table
	semantic-toplevel-bovine-table-source "rfc2445.bnf")
  (setq semantic-flex-keywords-obarray ical-keyword-table)
  ( setq semantic-case-fold t )
 
  ;; End code generated from rfc2445.bnf
  )

(add-hook 'ical-mode-hook 'ical-semantic-setup)

(defun mm ()
  (interactive)
  (save-excursion
    (with-current-buffer "rfc2445.el"
      (goto-char (point-min))
      (search-forward "defvar ical-bovine-table")
      (eval-defun nil)
      (goto-char (point-min))
      (search-forward "defun ical-semantic-setup")
      (eval-defun nil)))
  (normal-mode)
  (semantic-clear-toplevel-cache)
  (bovinate))

;;; Testing exprs ...  Delete before release

;; (let ((buf (get-buffer "one.ics")))
;;   (unfold-buffer buf))

;; (let ((buf (get-buffer "one.ics")))
;;   (fold-buffer buf))

;; (let ((buf (get-buffer "one.ics")))
;;   (print (conforms-to-rfc buf)))

;; (setq ssss "\r\n ")

(provide 'rfc2445)

(run-hooks 'ical-load-hook)

;;; rfc2445.el ends here.
