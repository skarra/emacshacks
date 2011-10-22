(require 'man)

;; `parse-colon-path' from files.el has a reputation for creating null
;; elements for redundant semi-colons and trailing /.  lets clean house
;; this function copied verbatim from woman.el of Francis J. Wright.
(defun ran-man--parse-colon-path (cd-path)
  (if (and (eq system-type 'windows-nt) (string-match "//" cd-path))
      (let ((path-separator ":"))
	(mapcar
	 (function
	  #'(lambda (path)			 
	    (cond ((string-match "\\`//" path)	 
		   (setq path (substring path 1))
		   (aset path 0 (aref path 1))	 
		   (aset path 1 ?:)))
	    path))
	 (parse-colon-path cd-path)))
    (parse-colon-path cd-path)))

(defun ran-man--get-manpath ()
  (let ((manpath (getenv "MANPATH")))
    (if manpath
	(ran-man--parse-colon-path manpath)
      (prog2
	  (message "$MANPATH is empty.  Trying /usr/man and /usr/local/man")
	  '("/usr/man" "/usr/local/man")))))

(defun ran-man--get-file-recursively (level vec &optional str)
  (cond
     ((eq level 0)
      (let* ((path (ran-man--get-manpath))
	     (pathv (vconcat [] path))
	     (size (length pathv))
	     (ran (% (abs (random)) size)))
	(if (eq size 0)
	    (error "manpath is empty.  Impossible...")
	  (ran-man--get-file-recursively 1 (vector (aref pathv ran)) str))))
     
     ((eq level 1)
      (let* ((man-dir (aref vec 0)))
	(if man-dir
	    (if (file-directory-p man-dir)
		(let* ((filess (vconcat []
					(directory-files man-dir t "man.*")))
		       (size (length filess))
		       (ran (% (abs (random)) size)))
		  (if (eq size 0)
		      (ran-man--get-file-recursively 0 [])
		    (let* ((dir (aref filess ran))
			   (maan (file-name-nondirectory dir))
			   (section (substring maan 3 (length maan))))
		      (message section)
		      (ran-man--get-file-recursively 2
						     (vector dir)
						     section))))
	      (error "Error in Manpath variable."))
	  (error "Error in Manpath variable."))))
     
     ((eq level 2)
      (let ((man-dir (aref vec 0)))
	(if man-dir
	    (if (file-directory-p man-dir)
		(let* ((filess (vconcat []
					(directory-files man-dir t "[^\.].*")))
		       (size (length filess))
		       (ran (% (abs (random)) size)))
		  (if (eq size 0)
		      (ran-man--get-file-recursively 0 [])
		    (let* ((fil (file-name-sans-extension (aref filess ran)))
			   (fi (file-name-nondirectory fil)))
		      (if (string= str "")
			  (man fi)
			(man (concat "-s " str  " " fi))))))
	      (error "Error in Manpath variable."))
	  (error "Error in Manpath variable."))))))

(defun random-man ()
  (interactive)
  (ran-man--get-file-recursively 0 []))
