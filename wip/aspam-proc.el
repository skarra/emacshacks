
;; Karra <karra@cs.utah.edu>:
;; Fri Nov 30 21:59:15 2001

;; This file is eventually meant to accomplish the following:

;; * Read in a given gnus score file, and for all "from" type entries,
;;   generate procmail recipes, sending them to /dev/null.
;;
;; * we already have a C-c x bound to some scum-expunging function.
;;   write a hook function that can be called from there so that an
;;   appropriate procmail recipe can be written as well.

;; Status of the code:
;; The interactive function spam-procify is in working condition.

(defvar spam-dump-file (expand-file-name "~/Mail/SPAM")
  "file to which all filtered spam should be diverted.")

(defvar spam-score-file (expand-file-name "~/News/SPAMMERS")
  "Score file containing all the spammer scores.")

(defun update-dot-forward ()
  t)

(defvar procmail-rc (expand-file-name "~/.procmailrc"))

(defun spam-procify ()
  "A la main ()..."
  (interactive)

  (update-dot-forward)
  (let ((spammers (list-all-spammers spam-score-file))
	(buf (find-file procmail-rc))
	where)

    (beginning-of-buffer)

    (mapcar
     (lambda (who)
       (beginning-of-buffer)       
       (setq where (search-forward
		    (concat "* ^From:.*"
			    (regexp-quote who))
		    nil t))
       (if (not (eq where nil))
	   (progn
	     (beginning-of-line)
	     (kill-line -1) ;; Kill the :0 line but leave an empty line
	     (kill-line 3)  ;; Kill the entire recipe & empty line
	     ))
       
       (end-of-buffer)
       (insert (concat "\n:0\n"
		       "* ^From:.*"
		       (regexp-quote who)
		       "\n"))
       (insert (concat spam-dump-file "\n")))
     spammers)

    (replace-regexp "\n\n+" "\n\n" nil (point-min) (point-max))
    (save-buffer buf))
;;     (set-file-modes (buffer-file-name buf)
;; 		    mode-for-dot-procmailrc)
  (message "Finished dumping list..."))

;; There are two versions of the list-all-spammers function.  There
;; could be some performance difference between the two.  An important
;; TODO is to estimate the difference, and to figure out why there is
;; any.

(defun list-all-spammers (spammers-file)
  "Return a list of email addresses from `spammers-file'.
spammers-file is the name of the score-file containing all spammers
scores."

  (let ((all-scores (gnus-score-load-score-alist spammers-file))
	lis)
    (while (and all-scores
		(not (string= (car (car all-scores)) "from")))
      (setq all-scores (cdr all-scores)))
    
    (when (string= (car (car all-scores)) "from")
      (let ((from-scores (cdr (car all-scores))))
	(while from-scores
	  (setq lis (cons (car (cdr (mail-extract-address-components
				     (car (car from-scores)))))
			  lis))
	  (setq from-scores (cdr from-scores)))))
    lis))

(defun list-all-spammers (spammers-file)
  "Return a list of email addresses from `spammers-file'.
spammers-file is the name of the score-file containing all spammers
scores."

  (let ((all-scores (gnus-score-load-score-alist spammers-file)))
    (while (and all-scores
		(not (string= (car (car all-scores)) "from")))
      (setq all-scores (cdr all-scores)))
    
    (when (string= (car (car all-scores)) "from")
      (let ((from-scores (cdr (car all-scores))))
	(mapcar (lambda (element)
		  (print element)
		  (car (cdr (mail-extract-address-components
			     (car element)))))
		from-scores)))))
