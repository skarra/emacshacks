;;; lost.el -- auto sig insertion support for LOSTs.

;; Copyright (C) 2002, 2003, 2004 Sriram Karra.

;; Author	: Sriram Karra <karra@shakti.homelinux.net>
;; Version	: v0.02+
;; Last Updated	: Sun Oct 17 22:28:48 2004

;;; Distributed under the terms conditions of GNU GPL version 2.

;;; Commentary

;; This particular file you are reading can be used to interface with
;; the LOST documents from inside Emacs.   The features of this package
;; are:
;; * Insert a random LOST document at point `insert-random-lost'.
;; * Browse a list of all available LOSTs(by listing their subject line)
;;   and select one your choice to be inserted at point. `browse-lost'.

;; Both these facilities can be hooked into your emacs-based email-client
;; system.  Look up the documentation of these two functions.

;;; Installation

;; * Download the latest set of LOST documents from : <http???>
;;
;; * Copy this file into a directory that is in your load-path.  e.g.
;;   ~/elisp/.  If you do not know what this means, do this:
;;   - create a directory ~/elisp
;;   - put the following at the very beginning of your ~/.emacs:
;;     (add-to-list 'load-path (expand-file-name "~/elisp/"))
;;   Now, any files you put in ~/elisp will "be in your load-path".
;;
;; * Modify the value of `lost-dir' (preferably in your ~/.emacs) to
;;   where you installed the lost directories.  This should be the value
;;   of the top level LOST directory (the default value is only an
;;   example.)  You can do this with a statement like
;;   (setq lost-dir (expand-file-name ~/LOSTS"))  in your ~/.emacs
;;
;; * put the following line in your ~/.emacs: (require 'lost)

;;; Usage:

;; At this point in time, two commands are useful: `insert-random-lost'
;; and `browse-lost'.  The former is most suitable for placing in
;; message sending hooks.  The latter is useful if you want to insert a
;; specific LOST - believe me, this is actually more useful than you
;; might think.

;;; TODO

;; * When viewing a listing of LOST subject lines, it might soon become
;;   necessary to allow the user to request only a subset of all
;;   available losts.  In other words, the function `browse-lost' should
;;   take a regexp that should be checked with the subject lines of all
;;   the LOSTs.
;;
;; * Include examples of how these functions can be used with specific
;;   mail clients Gnus, VM and Rmail.

;;; ChangeLog:

;; Changes since v0.02
;; * rename select-lost to browse-lost.
;; * New LOST-mode command 'i' as an alias for 'insert-current-lost
;; * New LOST-mode command 'd' for displaying snippets in a temporary
;;   buffer. 
;;
;; Changes between v0.01 and v0.02 (release Apr 6)
;; * font-lock enabled the major mode
;; * keybindings for "n" and "p"
;; * Make the buffer produced by M-x browse-lost read-only by default
;; * wrap the body of browse-lost in a save-excursion.

;;; Code

(defvar lost-dir (expand-file-name "~/etc/signature/LOST"))

;; Hopefully, there will be more keybindings here :-)
(defvar lost-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "i" 'insert-current-lost)
    (define-key map "n"  'forward-line)
    (define-key map "p"  'lost-backward-line)
    (define-key map "d"  'display-current-lost)
    map)
  "Local keymap for LOST mode buffers.")

(define-derived-mode lost-mode fundamental-mode "LOST"
  "Major mode for displaying info about LOST docs."
  (set (make-local-variable 'font-lock-defaults)
       '(lost-font-lock-keywords nil t))
  (use-local-map lost-mode-map))

(defvar lost-font-lock-keywords
  '("^Sub"
    (": \\(.*\\)LOST" 1 font-lock-string-face)
    ("LOST #[0-9]+" .
     font-lock-comment-face)))

;; There is something wrong here... Why do I need to write a simple
;; thingy like this?
(defun lost-backward-line ()
  (interactive)
  (forward-line -1))

(defvar lost-buf (get-buffer-create "*LOST Headers*")
  "Buffer holding LOST header info.")

(defvar lost-disp-buf-name "*LOST Snippet*")

(defvar lost-disp-buf (get-buffer-create lost-disp-buf-name)
  "Buffer holdling the LOST snippets when displayed via browse-lost")

(defvar lost-mark nil)

(defvar cached-lost-headers nil
  "Cached alist of header/filename pairs.
Reading in hundreds of small files and grepping it for patterns might be
time consuming.  In most cases it would suffice to just read in this
info once and keep it around somewhere.  This variable is the place
holder for just that info.")

;;;###autoload
(defun browse-lost ()
  "Select a LOST document from a list of all available LOSTs.
A new buffer is created and the subject lines are displayed.  The buffer
is in the \"LOST-mode\".  Pressing \"RET\" will insert the entire LOST
file corresponding to the current line at point in the buffer from where
you invoked `browse-lost'."
  (interactive)
  (setq lost-mark (point-marker))
  (split-window)
  (other-window 1)
  (display-lost-headers)
  (other-window 1)
  (unless (eq major-mode 'lost-mode ) (lost-mode))
  (toggle-read-only t))

(defun insert-current-lost ()
  "Insert LOST file corresponding to current line at point.
This function will insert the 'current lost' at the point marked by
lost-mark.  This is not really meant for direct user invocation."
  (interactive)
  (save-excursion
    (when (eq (current-buffer) lost-buf)
      (beginning-of-line)
      (when (re-search-forward "LOST #\\([0-9]*\\)" nil t)
	(let ((value (match-string 1)))
	    (other-window -1)
	    (switch-to-buffer (marker-buffer lost-mark))
	    (goto-char (marker-position lost-mark))
	    (insert-file (concat lost-dir "/" value ".lost")))))))
  
(defun display-current-lost ()
  "Display the LOST in current line the LOST snippet buffer."
  (interactive)
  (let ((t-mark))
    (save-excursion
      (unless (buffer-name lost-disp-buf)
	(setq lost-disp-buf (get-buffer-create lost-disp-buf-name)))
      (set-buffer lost-disp-buf)
      (delete-region (point-min) (point-max))
      (setq t-mark (point-marker)))
    (let ((lost-mark t-mark))
      (insert-current-lost))
    (switch-to-buffer-other-window lost-buf)))

(defun cache-lost-headers ()
  "Populate the variable `cached-lost-headers'.
The assumption is the LOST headers are displayed in the `lost-buf'
buffer.  "
  (interactive)
  (setq cached-lost-headers nil)
  (save-excursion
    (set-buffer lost-buf)
    (beginning-of-buffer)
    
    ;; We make the assumnption that the LOST buffer has not been mucked
    ;; around with. and that each line contains the subject line from
    ;; one LOST...  If the user has made some mods, he deserves
    ;; whatever he gets...
    (while (re-search-forward
	    "^Sub\\ *:\\ *\\(.*\\)LOST #\\([0-9]*\\)" nil t)
      (setq cached-lost-headers
	    (cons (cons (match-string 1)
			(concat (match-string 2) ".lost"))
		  cached-lost-headers)))))

(defun display-lost-headers ()
  (interactive)
  (unless (not (or (not lost-buf)
		   (null (buffer-name lost-buf))))
    (setq lost-buf (get-buffer-create "*LOST Headers*")))
  (shell-command
   (format
    "find %s -name [0-9]*.lost | xargs egrep -h \"^Sub\\ *:\""
    lost-dir)
   lost-buf))

;;;###autoload
(defun insert-random-lost ()
  "Inserts a random LOST file from `lost-dir' at point (i.e. cursor)."
  (interactive)
  (let* ((files (vconcat (directory-files lost-dir t "[0-9]*.lost")))
	 (len (length files))
	 (ran-index (% (abs (random t)) len))
	 (random-lost-fname (aref files ran-index)))
    (insert-file random-lost-fname)))

;;; Commented out code:

;; There are some routines here that would come in handy when proper
;; shell commands cannot issued from inside Emacs.  This can happen if a
;; person uses NTEmacs, and does not have cygwin tools.  In this case
;; the following might come in handy.  Ofcourse, this is only a minor
;; hint.  To get it to actually work in that setup would require some
;; effort in addition to uncommenting out the following code.  I would
;; be especially happy to recieve mods for this stuff.

;; (defun extract-lost-headers (&optional switch)
;;   "Return a list of headers of all available LOST documents.
;; The subject lines from all available LOST documents are extracted and
;; returned as an alist of the format:
;; ((\"Sub : Deleting Vi (#1) LOST #200\" . \"200.lost\")
;;  ...)
;; This alist can then be put to some good use.  The value of the global
;; variable `cached-lost-headers' is properly initialised as well.  An
;; example of a function that uses this alist is `display-lost-headers'."

;;   (interactive)
;;   (let ((files (directory-files lost-dir t "[0-9]*.lost"))
;; 	buf file
;; 	(headers (list)))

;;     (while files
;;       (setq file (car files))
;;       (setq buf (find-file file))
;;       (beginning-of-buffer)
;;       (re-search-forward "^Sub\\ *:\\ .*$")
;;       (setq headers (cons (cons (concat (match-string 0) "\n")
;; 				file)
;; 			  headers))
;;       (kill-buffer buf)
;;       (setq files (cdr files)))

;;     (when switch
;;       (switch-to-buffer lost-buf))
;;     (setq cached-lost-headers headers)))

;; The commented  out code is a  much slower version of  one above.  The
;; combination of  find and  xargs is much  faster than loading  tons of
;; files into  Emacs and searching  them.  However, it is  possible that
;; some  guy would  use this  file in  NTEmacs and  not have  the cygwin
;; tools...  So having the second function around is quite handy.  Maybe
;; sometime this code  should be rewritten such that  the right defun is
;; visible depending on some variable.

;; (defun display-lost-headers (&optional dont-use-cache)
;;   "Display the header of all available LOST documents in a buffer.
;; The subject line from the LOST documents available in the `lost-dir'
;; directory are extracted and displayed in a buffer named *LOST Headers*.
;; Reading in and processing all those files is a time consuming process;
;; to avoid delay, a cached list of headers is maintained.  If this list of
;; non-nil, its contents are displayed.  This use of cached values can be
;; overruled with a prefix argument in the call."
;;   (interactive "P")
;;   (let ((headers (or (or (and dont-use-cache
;; 			      (extract-lost-headers))
;; 			 cached-lost-headers)
;; 		     (extract-lost-headers)))
;; 	(lost-buf (get-buffer-create "*LOST Headers*")))	
;;     (save-excursion
;;       (set-buffer lost-buf)
;;       (while headers
;; 	(insert (car (car headers)))
;; 	(setq headers (cdr headers)))))
;;   (message "Done generating LOST headers."))  

(provide 'lost)

;;; lost.el ends here
