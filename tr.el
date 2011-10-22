;; -*-emacs-lisp-*-

(defun make-range (from to)
  (let ((res))
    (while (<= from to)
      (setq res (cons to res))
      (setq to (- to 1)))
    res))

(defun expand-all-ranges (string)
  (let ((len (- (length string) 2))
	(index 0)
	(result (vconcat))
	(curr-char)
	(next-char))
    (while (< index len)
      (setq curr-char (aref string index)
	    next-char (aref string (+ index 1)))
      (if ( = (aref string (+ index 1)) ?-)
	  (progn
	    (setq result
		  (append result
			  (make-range curr-char
				      (aref string
					    (+ index 2)))))
	    (setq index (+ index 3)))
	(prog2
	    (setq result
		  (append result (list curr-char)))
	    (setq index (+ index 1)))))
    (while (<= index (+ len 1))
      (setq result
	    (append result (list (aref string index))))
      (setq index (+ index 1)))
    result))

(defun tr (orig modi string)
  (let* ((from-vec (expand-all-ranges orig))
	 (to-vec   (expand-all-ranges modi))
	 (temp     (- (length from-vec)
		      (length to-vec)))
	 (table))
    (when (> temp 0)
      (setq to-vec
	    (append to-vec
		    (make-list temp
			       (aref modi
				     (- (length modi) 1))))))
    (require 'cl)
    (setq table (make-translation-table (mapcar* 'cons
						 from-vec
						 to-vec)))
     (concat (mapcar (lambda (char)
		       (let ((ch (aref table char)))
			 (if ch
			     ch
			   char)))
		     string))))
