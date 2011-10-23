(defmacro load-library-carefully (lib &optional initial-hook final-hook
				      fail-func)
  "Load `lib' with error checks.
This function loads lib if available., and just prints a message if that
library is not available.  You can provide a function name as the fourth
argument, and that function will be run instead.  This is useful if we
are loading a crucial library, and cannot continue without it.  The
(optional) second  and third arguments are  hooks, which need  to be run
before and after the library is loaded (if available)."
(let ((lib-name (cond ((symbolp (eval lib))
		       (symbol-name lib))
		      ((stringp lib)
		       lib)
		      (t lib)))
      (ret-list (list)))

  (message "S = %s" lib-name)
  (if (locate-library lib-name)
      (when initial-hook
;	(setq ret-list `(funcall ,initial-hook))

	(if (symbolp lib)
	    (setq ret-list (cons ret-list `(require ,lib)))
	  (setq ret-list (cons ret-list `(load-library ,lib))))

;; 	(when final-hook
;; 	  (setq ret-list (cons ret-list `(funcall ,final-hook))))

	(setq ret-list (cons 'progn ret-list))

	t)
    )))
;;     (if fail-func
;; 	(funcall fail-func)
;;       (message (concat "library " lib-name " not found dude."))))))

(load-library-carefully boxquote)

(defmacro get-lib-name (a)
  (if (symbolp (eval a))
      (list 'require a)
    (list 'load-library a)))

(macroexpand '(l ps-print))
