
(require 'woman)

(if (or
     (and woman-expanded-directory-path woman-topic-all-completions)
     (woman-read-directory-cache))
    ()
  (message "Building list of manual directory expansions...")
  (setq woman-expanded-directory-path
	(woman-expand-directory-path woman-manpath woman-path))
  (message "Building completion list of all manual topics...")
  (setq woman-topic-all-completions
	(woman-topic-all-completions woman-expanded-directory-path))
  (woman-write-directory-cache))

(let (
