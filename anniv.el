;;; anniv.el -- Make anniversary entries for Emacs diary from BBDB
;;              fields

;;; Written by: Sriram Karra <karra@cs.utah.edu>

;;; *** L I C E N S E ***

;; Distributed under GPL (version 2 only)

;;; Notes

;; The Emacs diary contains facilities to remind us of anniversaries...
;; and we can store the info in BBDB.  The natural thing to do is to
;; extend the darned thingies...  :)
;;
;; This file attempts to do the above.  There already exists a file
;; called bbdb-anniv.el in the bbdb/bits directory.  That file, although
;; distributed along with the bbdb tar balls is not to be considered as
;; being part of bbdb :)  In any case, I wrote this file before I looked
;; into bbdb-anniv.el  -- that file has support for atleast two types of
;; anniversaries, and so on.
;;
;; Usage:
;;
;; Display the records you are interested in in the *BBDB* buffer.  Then
;; type M-x karra-add-all-annivs RET This will add entries into the
;; .diary file.  The default is to setup reminders for one day prior to
;; the thingy.

;; For this addition to work, your bbdb records should have a field
;; "d.o.b" and the value should be a string of the form "18 Jun 1977"
;; etc.  The month should be _only_ 2 letters, and there _should_ be a
;; year.

;;; Code

(defun karra-add-all-annivs ()
  "Add d.o.b entries from BBDB as anniversary entries in the diary."
  (interactive)
  (let ((records (prog2
		     (set-buffer bbdb-buffer-name)
		     bbdb-records))
	record dob message)
    (while records
      (setq record (car (car records)))
      (setq message (concat (bbdb-record-firstname record)
			    "'s %d%s birthday"))
      (setq dob (bbdb-record-getprop record 'd\.o\.b))
      (unless (null dob)
	(setq dob (karra-format-dob dob))
	(karra-add-anniv dob message))
      (setq records (cdr records)))))

(defvar karra-month-num
  '(("Jan"       . "1")
    ("January"   . "1")
    ("Feb"       . "2")
    ("February"  . "2")
    ("Mar"       . "3")
    ("March"     . "3")
    ("Apr"       . "4")
    ("April"     . "4")
    ("May"       . "5")   
    ("Jun"       . "6")
    ("June"      . "6")
    ("Jul"       . "7")
    ("July"      . "7")
    ("Aug"       . "8")
    ("August"    . "8")
    ("Sep"       . "9")
    ("September" . "9")
    ("Oct"       . "10")
    ("October"   . "10")
    ("Nov"       . "11")
    ("November"  . "11")
    ("Dec"       . "12")
    ("December"  . "12")))

(defun karra-format-dob (dob &optional sep)
  "Convert a date in the format \"18 Jun 1977\" to 6 18 1977.
If optional argument sep is set to something, it is used instead of ' '
to separate the day, month and year fields."

  (let* ((sep (if sep sep " "))
	 (lux (string-match "\\([0-9][0-9]?\\) \\([a-zA-Z][a-z][a-z]+\\) \\([0-9][0-9][0-9][0-9]\\)" dob))
	 (date (when lux (match-string 1 dob)))
	 (mon (when lux (match-string 2 dob)))
	 (month (when lux (cdr (assoc mon karra-month-num))))
	 (year (when lux (match-string 3 dob))))

    (if lux (if (and (boundp 'european-calendar-style)
		     european-calendar-style)
		(concat date sep month sep year)
	      (concat month sep date sep year))
      (prog2
	  (message "Warning !! D.O.B %s unparseable." dob)
	  ""))))

(defun karra-add-anniv (date message)
  "Internal Function.
Add a diary entry for the given date with the given message."
  (save-excursion
    (let* ((calendar-date-display-form
	    (if european-calendar-style
		'(day " " month " " year)
	      '(month " " day " " year)))
	   (diary-entry (format (concat "%s(diary-remind "
					"'(diary-anniversary %s) 1)")
				sexp-diary-entry-symbol
				date)))
      (find-file-other-window
       (substitute-in-file-name diary-file))
      (goto-char (point-min))
      (unless (re-search-forward (regexp-quote 
				  (concat diary-entry " " message))
				 nil t)
	(goto-char (point-max))
	(insert
	 (if (bolp) "" "\n")
	 (concat diary-entry " " message))))))

;;; anniv.el ends here.
