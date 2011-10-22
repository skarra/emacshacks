;;; This is bbdb-to-outlook.el, version 0.1 -*- fill-column: 79 -*-
;;;
;;; $Id$
;;;
;;; Author: Bin Mu <mubin@cs.uchicago.edu> 
;;;                <http://www.cs.uchicago.edu/~mubin>
;;; Created: 30 Oct 1997
;;; Version: 0.1
;;;
;;; bbdb-to-outlook is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation; either version 1, or (at your option) any later
;;; version.
;;;
;;; bbdb-to-outlook is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;;
;;; This module is for exporting BBDB databases into a comma delimited 
;;; text file, which can be imported into microsoft outlook contact forms and
;;; ms address book.
;;;
;;; USE:  In the *BBDB* buffer, type O to convert the listing to text format.
;;;       It will prompt you for a filename.  And then you can import the file
;;;       into Microsoft outlook contacts and outlook express address boook 
;;;       etc.
;;;
;;; INSTALLATION: Put this file somewhere on your load-path.
;;;       Put (require 'bbdb-to-outlook) in your .emacs, or autoload it.
;;;
;;; 

(require 'bbdb)
(require 'bbdb-com)

(define-key bbdb-mode-map "O" 'bbdb-to-outlook)

;;;
;;; Variables
;;;

(defvar bbdb-to-outlook-file-name "~/bbdb.txt"
  "*Default file name for printouts of BBDB database.")

(defvar bbdb-to-outlook-field-map
  (("First Name" . t)
   ("Last Name"  . t)
   ("Company"    . t)
   ("Home"       . "Home Phone")
   ("Work Phone" . "Business Phone")
   ("Home Phone" . t)
   ("Mobile"     . "Car Phone")
   ("Pager"      . t)
   ("Other Phone" . t)

(defvar bbdb-to-outlook-prolog 
  (concat "\"First Name\""
	  ",\"Last Name\""
	  ",\"Company\"" 
	  
	  ;; phones
	  ",\"Business Phone\""
	  ",\"Home Phone\""
	  ",\"Business Fax\""
	  ",\"Car Phone\""
	  ",\"Pager\""
	  ",\"Other Phone\""

	  ;; EMAIL
	  ",\"E-mail Address\""
	  ",\"E-mail 2 Address\""
	  ",\"E-mail 3 Address\""
	  
	  ;; addresses
;; 	  ",\"Business Street\""
;; 	  ",\"Business City\""
;; 	  ",\"Business State\""
;; 	  ",\"Business Postal Code\""
	  
	  ",\"Home Street\""
	  ",\"Home City\""
	  ",\"Home State\""
	  ",\"Home Postal Code\""

	  ",\"Birthday\""

	  ;; notes
	  ; ",\"Nickname\"" doesn't work
	  ",\"Notes\""

	  ;; end of prolog
	  "\n"
	  )
  "*TeX statements to include at the beginning of the bbdb-to-outlook file.")

(defvar bbdb-to-outlook-epilog ""
  "*TeX statements to include at the end of the bbdb-to-outlook file.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun bbdb-to-outlook (to-file)
  "Outlook the selected BBDB entries"
  (interactive (list (read-file-name "To File: " bbdb-to-outlook-file-name)))
  (setq bbdb-to-outlook-file-name (expand-file-name to-file))
  (let ((current-letter t)
	(records (progn (set-buffer bbdb-buffer-name)
			bbdb-records)))
    (find-file bbdb-to-outlook-file-name)
    (delete-region (point-min) (point-max))
    (while records
      (setq current-letter 
	    (bbdb-to-outlook-format-record (car (car records)) current-letter))
      (setq records (cdr records)))
    (goto-char (point-min)) (insert bbdb-to-outlook-prolog)
    (goto-char (point-max)) (insert bbdb-to-outlook-epilog)
    (goto-char (point-min))))

(defun bbdb-to-outlook-format-record (record &optional current-letter brief)
  "Insert the bbdb RECORD in TeX format.
Optional CURRENT-LETTER is the section we're in -- if this is non-nil and
the first letter of the sortkey of the record differs from it, a new section
heading will be outlook \(an arg of t will always produce a heading).
The new current-letter is the return value of this function.
Someday, optional third arg BRIEF will produce one-line format."
  (bbdb-debug (if (bbdb-record-deleted-p record)
		  (error "plus ungood: tex formatting deleted record")))
  
  (let* ((first-letter 
	  (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	 (lname   (and (bbdb-field-shown-p 'name)
		       (bbdb-record-lastname record)))
	 (fname   (and (bbdb-field-shown-p 'name)
		       (bbdb-record-firstname record)))
	 (comp   (and (bbdb-field-shown-p 'company)
		      (bbdb-record-company record)))
	 (net    (and (bbdb-field-shown-p 'net)
		      (bbdb-record-net record)))
	 (phones (and (bbdb-field-shown-p 'phone)
		      (bbdb-record-phones record)))
	 (addrs  (and (bbdb-field-shown-p 'address)
		      (bbdb-record-addresses record)))
	 (aka    (and (bbdb-field-shown-p 'aka)
		      (bbdb-record-aka record)))
	 (dob    (bbdb-record-getprop record 'd\.o\.b))
	 (notes  (bbdb-record-raw-notes record))
	 (begin (point)))
    
    ;; Section header, if neccessary.
    
    ;; name
    (insert (format "\"%s\"" (bbdb-to-outlook-if-not-blank fname)))
    (insert (format ",\"%s\"" (bbdb-to-outlook-if-not-blank lname)))
    (insert (format ",\"%s\"" (bbdb-to-outlook-if-not-blank comp)))

    ;; Phone numbers
    (insert (bbdb-to-outlook-phone phones "work\\|office"))
    (insert (bbdb-to-outlook-phone phones "home"))
    (insert (bbdb-to-outlook-phone phones "fax"))
    (insert (bbdb-to-outlook-phone phones "car\\|mobile"))
    (insert (bbdb-to-outlook-phone phones "page"))
    (insert (bbdb-to-outlook-phone phones "\\(home (\\)\\|india"))

    ;; Email address
    ;; at most three email address
    (insert (format ",\"%s\"" (bbdb-to-outlook-if-not-blank (car net))))
    (setq net (cdr net))
    (insert (format ",\"%s\"" (bbdb-to-outlook-if-not-blank (car net))))
    (setq net (cdr net))
    (insert (format ",\"%s\"" (bbdb-to-outlook-if-not-blank (car net))))
    (setq net (cdr net))

    ;; Addresses
    (insert (bbdb-to-outlook-address addrs "work\\|office"))
;;;    (insert (bbdb-to-outlook-address addrs "home"))

    (insert (format ",\"%s\"" (convert-date-to-us dob)))

    ;; Notes
    (if (stringp notes)
	(setq notes (list (cons 'notes notes))))

    (insert ",\"")
    (while notes
      (let ((thisnote (car notes)))
	(unless (eq (car thisnote) 'd\.o\.b)
	  (if (bbdb-field-shown-p (car thisnote))
	      (progn
		(if (eq 'notes (car thisnote))
		    (insert (format "Note:  %s\n" 
				    (bbdb-print-outlook-quote (cdr thisnote))))
		  (if (not (eq 'mail-folders (car thisnote)))
		      (insert (format "%s:  %s\n" 
				      (bbdb-print-outlook-quote 
				       (symbol-name (car thisnote)))
				      (bbdb-print-outlook-quote 
				       (cdr thisnote))))))))))
      (setq notes (cdr notes)))

    (if aka (insert (format "AKA: %s\n" 
			    (mapconcat (function identity) aka ", "))))

    (insert "\"")
    
    ;; end of everything
    (insert "\n")
    ;; If record is bare, delete anything we may have inserted.
    ;; otherwise, mark the end of this record.
    current-letter))

(defun bbdb-to-outlook-if-not-blank (string &rest more)
  "If STRING is not null, then return it concatenated with rest of arguments.
If it is null, then all arguments are ignored and the null string is returned."
  (if (or (null string) (equal "" string))
  ""
  (apply 'concat string more)))

(defun bbdb-print-outlook-quote (string)
  "replace \" with \' in the string"
  (let (i)
    (while (setq i (string-match "\"" string i))
      (setq string (concat (substring string 0 i) "\'"
			   (substring string (1+ i))))))
  string)

(defun bbdb-to-outlook-phone (phones pattern)
  (let ((found nil)
	(result ",\"\""))
    (while (and phones (not found))
      (let ((place (downcase (aref (car phones) 0)))
	    (number (bbdb-phone-string (car phones))))
	(if (setq found (string-match pattern place))
	    (setq result (format ",\"%s\"" number)))
	(setq phones (cdr phones))))
    result))
  

(defun bbdb-to-outlook-address (addrs pattern)
  (message "Inside!!")
  (let ((found nil)
	(result ""))
    (or (and
	 addrs
	 (progn
	   (while addrs
	     (let ((place (downcase (aref (car addrs) 0)))
		   (addr (car addrs)))
	       (setq result
		     (concat
		      result
		      ",\""
		      (let ((streets (bbdb-address-streets addr))
			    (ret ""))
			(when streets
			  (setq ret (bbdb-to-outlook-if-not-blank
				     (car streets)))
			  (setq streets (cdr streets))
			  (while streets
			    (setq ret
				  (concat ret ","
					  (bbdb-to-outlook-if-not-blank
					   (car streets))))
			    (setq streets (cdr streets))))
			ret)
		      "\",\""
		      (bbdb-to-outlook-if-not-blank (bbdb-address-city addr))
		      "\",\""
		      (bbdb-to-outlook-if-not-blank (bbdb-address-state addr))
		      "\",\""
		      (bbdb-to-outlook-if-not-blank (bbdb-address-zip-string
						     addr)))))
	     (setq result (concat result "\""))
	     (setq addrs nil)) ; (cdr addrs))) settle for one addr :)
	   result))
	(setq result ",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\"")
	result)))

(defvar month-num
  '(("Jan" . "1")
    ("Feb" . "2")
    ("Mar" . "3")
    ("Apr" . "4")
    ("May" . "5")
    ("Jun" . "6")
    ("Jul" . "7")
    ("Aug" . "8")
    ("Sep" . "9")
    ("Oct" . "10")
    ("Nov" . "11")
    ("Dec" . "12")))

(defun convert-date-to-us (dob)
  "Convert a date in the format \"18 Jun 1977\" to 6/18/1977."

  (let* ((sux (if dob dob ""))
       (lux (string-match "\\([0-9][0-9]?\\) \\([A-Z][a-z][a-z]\\) \\([0-9][0-9][0-9][0-9]\\)" sux))
       (date (when lux (match-string 1 sux)))
       (mon (when lux (match-string 2 sux)))
       (month (when lux (cdr (assoc mon month-num))))
       (year (when lux (match-string 3 sux)))
       )

  (if lux
      (concat month "/" date "/" year)
    "")))

(provide 'bbdb-to-outlook)
