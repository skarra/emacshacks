;;; gg.el -- iCal support for gnus.

;;; Incomplete as of Sun Oct 17 22:37:36 2004


;;; Installation

;; Put the following in your ~/.emacs
;;
;; (autoload 'ical-mode "gg.el")

;;; Some generic functions

(defun fold-buffer (buf)
  "Implementation at home."
  )

(defun unfold-buffer (buf)
  "Implementation at home."
  )

;;; Setup the new major mode for editing ical files.

(defvar ical-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c \C-c" 'ical-parse-buffer)
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

(define-derived-mode ical-mode fundamental-mode "iCal"
  "A major mode for editing iCal objects"
  (set (make-local-variable 'font-lock-defaults)
       '(ical-font-lock-keywords nil t))
  (use-local-map ical-mode-map))

(provide 'ical-mode)

;;; Parsing related funcs

(defun ical-parse-buffer ()
  (message "Parsing buffer...done.")
  )

(defvar ical-flex-extensions
  '(("begin" . ical-begin)
    ("end"   . ical-end)))
