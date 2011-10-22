
;; The idea here is to extend c-mode with a useful command: Take a
;; function declaration and make the following modifications
;; * convert into a #define with the necessary number of arguments.
;; * The lines of code in the function body should be replaced with a
;;   do{}while(0) style single statement (with necessary "\"" at the
;;   necessary places and proper indentation.
;; * The former formal parameters that appear in the former function
;;   body will be surrouned by an additional pair of braces in the macro
;;   body.

(defun my-region-beginning ()
  " this is the same as (region-beginning) only that it doesnt blow up
on your face if the mark isnt active.  in that case, it just returns
point, because one way of looking at it is a region with the beginning
and the end at point"

  (interactive)
  (if mark-active
      (if (< (mark) (point))
	  (mark)
	(point))
    (point)))

(defun my-region-end ()
  " this is the same as (region-end) only that it doesnt blow up
on your face if the mark isnt active.  in that case, it just returns
point, because one way of looking at it is a region with the beginning
and the end at point"
  
  (interactive)
  (if mark-active
      (if (> (mark) (point))
	  (mark)
	(point))
    (point)))

;; the following is a function that takes a C-function and makes it
;; into a macro.  It should not be too hard to make it work for a C++
;; function either.

;; Latest status: It correctly parses simple C/C++ function headers
;; (and prints out relevant parts of the same
(defun po()
  (interactive)
  (let ((begin (my-region-beginning))
	(end   (my-region-end))
	(id-reg "\\(\\(\\sw\\|\\s_\\)+\\)"))
    (save-excursion
      (goto-char begin)
      (re-search-forward (concat id-reg "\\s-*"
				 (concat "\\(" id-reg "::\\)?")
				 id-reg "\\s-*"
				 (concat "\\((\\s-*"
					 id-reg "\\s-*" id-reg ".*\\)")))
      (message (match-string 1))
      (message (match-string 3))
      (message (match-string 6))
      (message (match-string 8)))))
