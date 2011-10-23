;; The following code _almost_ works.  There are serious problems, however
;; :)  What this means is, the idea is solid, but there are some hurdles in
;; the way of a good implementation.  They idea is that we hook on a
;; function that sends a "echo $PWD" kind of command to the shell, and sets
;; the variable `default' directory accordingly.  Now, this thing works by
;; hooking the required function to `comint-output-filter-functions'.  But
;; our own method produces shell output, and hence the above function is
;; called, and we are stuck in one hopeless loop.  So, we have to
;; temporarily turn that var to nil.  Therein lies the fly in the ointment
;; of our beautiful idea...  Bindig it locally with a (let ...) inside (ma)
;; does not work because clearly the decision to call the functions in
;; `comint-output-filter-functions' happens outside of this...  so we are
;; currently left with no option but to modify comint.el


(setq comint-output-filter-functions 
      (list 'ma))

(defun swallow (x)
;  (message (format "swallow called with %s" x))
  (if (string-match "\\(.*\\)\\\n.*" x)
      (progn
	(setq default-directory (match-string 1 x))
	"")
    x))

(swallow "Matter
")

(setq comint-preoutput-filter-functions (list 'swallow))
(setq comint-preoutput-filter-functions nil)

(defun ma (a)
  (interactive)
  (let ((proc (get-buffer-process (current-buffer)))
;	(comint-output-filter-functions nil)
	(comint-preoutput-filter-functions (list 'swallow)))
    (comint-send-string proc "echo $PWD\n"))
;  (setq comint-output-filter-functions (list 'ma))
  a)
      (while (not (looking-at ".+\\n"))
	(accept-process-output proc))
