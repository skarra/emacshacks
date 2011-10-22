;;; rmail-block-sender.el - (set up procmail to) block addresses.

;; Copyright (C) 2000, 2001 Sriram Karra

;; Author     : Sriram Karra <karra@cs.utah.edu>
;; Maintainer : Sriram Karra <karra@cs.utah.edu>
;; Created    : Thu Sep 28 2000
;; Keywords   : procmail, block, spam

;; This file is not part of GNU Emacs; nor is it part of XEmacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; version 2.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Emacs; see the file COPYING.  If not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.

;;; Installation

;; save this file into a directory that is in your `load-path'.  Then
;; you put the following in your ~/.emacs
;; (require 'rmail-block-sender)
;; To use the functionality provided by this package from within
;; rmail, add the following to your ~/emacs
;; (add-hook 'rmail-mode-hook
;; 	  (lambda ()
;;  	    (define-key rmail-mode-map "F" 'rmail-block-sender)
;; 	    (define-key rmail-summary-mode-map "F" 'rmail-block-sender)))

;;; Commentary

;; You can find the most recent version of this file at:
;; ftp://ftp.cs.utah.edu/users/karra/rmail-block-sender.el

;; This pseudo-package provides some functions that allow the
;; automatic generation of information needed by the popular mail
;; filter procmail, to filter emails coming from certain addresses.
;; Given an email address, the function rmail-block-sender will do the
;; following:
;; 1. look for a ~/.forward file.  It is created if necessary.
;; 2. setup the ~/.forward file so that your mail delivery agent will
;;    run your mail through the specified filter (defaults to
;;    /usr/local/bin/procmail.  see `procmail-path'.
;; 3. look for a ~/.procmailrc, and emit the information necessary to
;;    block one email address.  By default future mails coming from
;;    the address are sent to /dev/null.  This can be customised using
;;    the `black-hole' variable.
;; 4. does nothing more.

;; There a bunch of customisable variables.  You can scroll down and
;; find them at the very top of the code.  Eachvariale declration has
;; a documentation string, which should tell you all you need to know
;; about that variable.

;; The only function that is intended as an entry to the outside world
;; is `rmail-block-sender'.  You can find documentation in its
;; definition.

;;; Caveats

;; You need to keep in mind that this add on to Rmail will only setup
;; procmail recipes.  Procmail can be invoked in a number of different
;; ways, and this code was written with a couple of common scenarios in
;; mind - procmail is called from your .forward and procmail is invoked
;; always at mail delivery time.
;;
;; And ofcourse, for best results, make sure you put the generated
;; procmailrc file on your mail server.  For example, if you use Rmail
;; on a dialup at home, you would be better off filtering off unwanted
;; mails before getting them home.  [ Actually, you _could_ try giving a
;; remote name for the .procmailrc file... but ... :-) ]

;;; Todo

;; would be nice if we could unblock blocked dorks.  We can just make
;; a pass through ~/.procmailrc, and create a list of blocked
;; addresses, and well nuke one of them from the list or some such.
;; should be very straightforward.

;;; code

(defvar procmail-path "/usr/local/bin/procmail"
  "The complete pathname of `procmail' program.
This information is needed to update your .forward file, which is one of
the two steps in the process of blocking an email address.  However,
this update is done only once, and is transparent for users of the
primary entry point, which is rmail-block-sender.")

(defvar black-hole "/dev/null"
  "File to which blocked senders' mail will be diverted to.
Since the primary use of this jack is to completely block out a
particular email address, the default is set to /dev/null.  But then,
maybe you just want to store them all up for later viewing?")

(defvar procmail-rc "~/.procmailrc"
  "Filename of your procmail resource file.
The string will be subject to a (expand-filename ...) before being used.
So, stuff like ~/ can be used safely")

(defvar dot-forward "~/.forward"
  "The path of your .forward file as needed by your mail delivery agent.
The string will be subject to a (expand-filename ...) before use.  So
stuff like ~/ can be used safely.  god knows why i am making this a
variable.")

(defvar mode-for-dot-forward 420
  "Decimal integer representing file access permissions for .forward.
The .forward file _has_ to be world readable.  The default corresponds
to -rw-r--r-- setting.  The file permissions are changed only if your
.forward file is changed.  For more information on the file permissions
and how to come up numbers and such, refer the Emacs Lisp reference
manual.")

(defvar mode-for-dot-procmailrc 420
  "Decimal integer representing file access permissions for .procmailrc.
The default corresponds to -rw-r--r-- setting.  It is not necessary to
keep this file world readable.  The permissions are fixed only if some
additions are made to your .procmailrc file.  For more information on
the file permissions and how to come up numbers and such, refer the
Emacs Lisp reference manual.")

(defvar update-dot-forward t
  "Wether or not procmail should be invoked from ~/.forward.
Some installations automatically route the mail through procmail, thus
eliminating the need for special directives in a ~/.forward type file.
In this case, you should set this variable to nil.  The default is to
put some stuff in your .forward.")

(defun rmail-block-sender (&optional who where)
  "Add sender of current mail to the blocked list.
This function enables you to blocks all future mail from a particular
sender.  It takes two optional arguments.  The first is a valid email
address.  The second is some place to divert all future mails from this
jerk.  The default for this is /dev/null.  You have to be within rmail
to be able to use this function without any arguments.  In that case,
the sender of the current-message is blcked : all future mails from
him/her/it are redirected to the `black-holed'.  There are a bunch of
variables you can optimise.  Look at `procmail-path', `procmail-rc',
`dot-forward', `black-hole', `mode-for-dot-forward',
`mode-for-dot-procmailrc'."
  (interactive)
  (if who
      (progn	
	(message (concat "blocking " who "..."))
	(get-rid who (if where
			 where
		       black-hole))
	(message (concat "blocking " who "...done.")))
    (save-excursion
      (or (eq major-mode 'rmail-mode)
	  (unless (eq rmail-buffer nil)
	    (switch-to-buffer rmail-buffer))
	  (error "Duh.  whats up with you."))
      (goto-char 0)
      (search-forward-regexp "^from: .*[^a-zA-Z0-9_\.\n]\\(.*@[a-zA-Z.]*\\)")
      (let ((whoever (match-string 1)))
	(message (concat "blocking " (match-string 1) "..."))
	(get-rid (match-string 1) (if where
				    where
				  black-hole))
	(message (concat "blocking " whoever "...done."))))))
  
(defun get-rid (who place)
  ;; put the necessary stuff in ~/.forward.  create the file if
  ;; necessary, and remember to fix the permissions to make the
  ;; darned file world readable
  (when update-dot-forward
    (let ((buf (find-file dot-forward)))
      (beginning-of-buffer)
      (let ((where (search-forward-regexp (concat "|\"IFS.*"
						  (regexp-quote procmail-path)
						  ".*$")
					  nil
					  t)))
	(if (eq where nil)
	    (progn
	      (end-of-buffer)
	      (insert (concat "|\"IFS=' '; exec "
			      procmail-path
			      " #" user-login-name "\""))
	      (save-buffer buf)
	      (set-file-modes (buffer-file-name buf)
			      mode-for-dot-forward))
	  (message "your .forward is all set"))
	(kill-buffer buf))))
  
  ;; put the necessary stuff in the ~/.procmailrc, creating it if
  ;; necessary, and also fix the permissions... 
  (let ((buf (find-file procmail-rc)))
    (beginning-of-buffer)
    
    (let ((where (search-forward-regexp (regexp-quote (concat "* ^From:.*"
							      who))
					nil t)))
      (if (eq where nil)
	  (progn
	    (end-of-buffer)
	    (insert (concat "\n:0\n"
			    "* ^From:.*"
			    who
			    "\n"
			    place
			    "\n\n"))
	    (save-buffer buf)
	    (set-file-modes (buffer-file-name buf)
			    mode-for-dot-procmailrc))
	(message "your .procmail is all set"))
      (kill-buffer buf))))

(provide 'rmail-block-sender)


;;; rmail-blocks-sender.el ends 
