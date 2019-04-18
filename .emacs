;;; ~/.emacs -- The file that is read in at Emacs startup time.

;; This is the new personal MacBookPro I purchased after I left HackerRank.
(setq whereami 'MacBookPro2016)

(when (file-exists-p "~/.cust.emacs")
  (load-file "~/.cust.emacs"))
