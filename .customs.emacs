;; ~/.customs.emacs - Emacs startup file, Sriram Karra
;;
;; $Id: .customs.emacs,v 1.13 2004/11/05 09:10:59 karra Exp $
;;
;; Last Modified	: Mon Dec 05 14:06:20 IST 2011 16:25:57 IST
;;
;; Emacs customisation file - called  from ~/.emacs.  You should be able
;; to  copy this entire  file over  into your  ~/.emacs and  life should
;; still be  good. UPDATE  May 12,  2001: Will have  to change  one line
;; atleast:  change  the  invocation  of the  byte-compile-nonsense  (to
;; ~/.emacs rather than ~/.customs.emacs)

;; WARNING: This  file has evolved  over three years without  any "real"
;; lisp programming knowledge;  As a result much horrendous  lisp can be
;; found  here, for  e.g.  my first  "big"  macro :-)  Lisp purists  are
;; advised to tread with caution.

;;; TODO:

;; * Tue  Nov 02  01:08:34 PST  2004: Need  to write  a macro  or  elisp
;;   function to do the following: given a view name, should load in all
;;   checked out files.  Wed Nov 03 02:38:08 PST 2004:  Done.  Check out
;;   find-all-cos
;;
;; * Thu Jun 10  11:34:25 2004: The 'whereami' approach to customisation
;;   is  not  really  working  ideally.   A more  flexible  approach  is
;;   required..  like we  need to  be able  'logically or'  a  number of
;;   location/os attributes; and even for location we need a finer grain
;;   of control.  For e.g. certain  printer name and paper size settings
;;   change on the same host depending  on where I am physically.  So we
;;   really  need a  physical  location attribute  and  a host  location
;;   attribute separation.
;;
;; * Fri Apr 9 13:43:10 2004: We should really have a package that
;;   should track all the keystrokes one makes in an emacs session and
;;   print out a listing sorted by count.  This info will be useful in
;;   choosign shorter keymappings for the frequently typed combos.
;; 
;; * Wed Oct 8 02:22:46 2003: should save the desktop automatically from
;;   time to time.  The conection  between sanjose and chennai is not as
;;   reliable as one would like ...
;; 
;; * The  k-lmod-*  stuff that  I  added on  2002-08-23  appears to  be
;;   somewhat similar  to what copyright-update does.  Maybe  it is time
;;   to extract the base functionality  for such updates into a specific
;;   package and  provide hooks for various individual  updates ??  Note
;;   on  Sun  Jun  15  23:54:23   2003  ->  There  is  something  called
;;   timestamp.el; check it out.
;;
;; * Convert  this file so it  is loadable in XEmacs as  well...  I have
;;   absolutely no  clue on this one:  maybe before the  spring break is
;;   over...Done.  The biggest hurdle is, ofcourse that there seem to be
;;   some incompailities  at the  .elc levels.  Since  we have a  ton of
;;   manually  installed  add-ons...well  life  sux  :-)  The  solution,
;;   ofcourse is to have just two dirs gnuelcs and xemacselcs which will
;;   contain _all_ the .elcs from all the manually installed packages...
;;   This looks like the only feasible solution.
;;
;; * It is quite a  pain to get new  keybindings - try  to automate the
;;   process.  Look, at say, a given keymap (C-x for e.g.) and return an
;;   unbound key sequence - this should be possible right ?
;;
;; * The  shell-mode's  directory  tracking  mechanism  is  pathetically
;;   naive.  Write a replacement for it.   The idea is to rebind the RET
;;   key  so that after  whatever needs  to be  done, issue  the command
;;   "echo   $PWD"   parse   the   output   and   set   the   value   of
;;   `default-directory' appropriately.  Update:- started work on this -
;;   find  time to  complete it.   file is  ~/elisp/crap.el .   C-u 1000
;;   (message "Learn  Lisp!")  Update May  28, 2001: crap.el has  made a
;;   "lot of  progress" or so I  thought...  Basically, I  now have code
;;   that does  exactly what M-x dirs  of shell.el does.   I just learnt
;;   about this function.   Looks like junta before me  got stuck at the
;;   same spot I am currently  in, because the functionality of M-x dirs
;;   almost  exactlty  matches  that  of  (ma) in  crap.el.   And  I  am
;;   basically stuck.  Got to do something about this man!
;;
;; * Currently,  soon after  new  mail  appears in  the  mail spool,  an
;;   indication appears  in the modeline.  This was  fine till recently;
;;   however, now I  am subscribed to some _really_  high volume mailing
;;   lists (india-linux-*) and constant popping  up of the this stuff is
;;   a tremendous strain.  I would also like to know if "more important"
;;   mails arrive.   Ofcourse, these lists  are currently at level  3 in
;;   Gnus...  So,  basically we have  to figure out  a way to  program a
;;   Gnus  demon that fetches  mail at  appropriate intervals,  and sets
;;   some global  flag iff there are  mails in levels  1-2.  Ofcourse, I
;;   guess using  procmail recipes  to split the  mail on  arrival would
;;   solve  the problem  (and sounds  like I  can do  it in  the  next 5
;;   minutes)... But that is not the point of this endeavor :)

;;; Generic setup code -- very basic and important routines.

;; Define certain macros that we can use to differentiate between the
;; different Emacs versions/flavours

(setq debug-on-error t)

(defmacro GNUEmacs (&rest x)
  (list 'if '(string-match "^GNU Emacs" (version)) (cons 'progn x)))

(defmacro XEmacs (&rest x)
  (list 'if '(string-match "^XEmacs" (version)) (cons 'progn x)))

(defmacro GNUEmacs21 (&rest x)
  (list 'if '(string-match "^GNU Emacs 21" (version)) (cons 'progn x)))

(defmacro GNUEmacs-old (&rest x)
  (list 'if '(and (string-match "^GNU Emacs" (version))
		  (< emacs-major-version 21))
	(cons 'progn x)))

(defmacro X-or-Emacs21 (&rest x)
  (list 'if (or (string-match "^GNU Emacs 21" (version))
		(string-match "^XEmacs" (version)))
	(cons 'progn x)))

;; We define a whole new kind of error thingy that we will use to
;; identify non-local exits we will be making from all over the freakin
;; place...

(put 'my-non-local-exit-error
     'error-conditions
     '(error my-errors my-non-local-exit-error))

(put 'my-non-local-exit-error 'error-message
     "This is not an error. Believe me. Ignore it ;-)")

;; Monday, September 24, 2001.  I  have slowly been moving away from the
;; idea  of  a  separate  machine-dependent customs  file.   Having  one
;; monolithc  .emacs  (or  .customs.emacs)  seems to  have  some  _real_
;; benefits.  Very  often, I loose  the machine dependent file  for some
;; sites when  I move from there.   This recently happened  when I moved
;; out of  Intel, Austin at the end  of my internship, because  I do not
;; have  access to  the  machine  I used  then.   Basically, having  one
;; customs file means fewer things to  remember to bring with you and we
;; can retain  all the specific  customizations for that place  as well;
;; For  example I had  successfully configured  ps-print on  NTEmacs and
;; been  using  quite happily  for  3 months.   Now  I  have lost  those
;; customizations; I would, ofcourse be  quite happy if I never _needed_
;; them again  :-) So... The following  variable will be  used to select
;; some special customizations, obviously :-]

(defvar whereami 'madras-laptop
  "Look at the leading comments in ~/.customs.emacs.
Value should be one of 'madras-laptop 'intel-home 'intel-office 'prodapt
'hcl 'hcl-nt 'hcl-linux")

(defmacro byte-compile-nonsense(filename &optional missing-dot-el elc-file)
  "Take care of loading .elc files that are older than .el files
Many times it  so happens that there are two versions  of files that can
be loaded by  Emacs - a source .el file and  a byte-compileed .elc file.
It is  a good thing  to bytecompile the  .el files.  It's  optimized for
various things, and  generally makes our life better.   However, it is a
fucking pain to  keep the two in  sync.  One solution would be  to add a
function to  the after-save-hook that can  check if the saved  file is a
..el file  and if  so, do  the needful.  However,  I am  in the  habit of
pressing C-x C-s whenever my fingers  rest.  So, this idea sounds like a
lot of crap.  This function does a much better job.

This function  sees if a file  has a bytecompiled version  that is older
than the corresponding  source.  If so, it bytecompiles  the file, loads
it and  exits.  It exits by calling  (error \"\"), because I  do not yet
know a way of making a non-local exit.

The idea  is to place this function  into _all_ .el files  we write, and
call it with the appropriate filename.

The first argument `filename' should be the part of the filename without
the trailing .el or .elc.  For  e.g. if you are considering putting this
function  at the  head  of the  file  scroll-in-place.el, this  function
should be invoked with scroll-in-place.

If  the  optional  second  argument  is  non-nil,  it  is  assumed  that
`filename' is the complete filename of the original source.  This option
exists to take care of cases like ~/.emacs which do not .el extensions.

The optional  third argument gives  the name of the  byte-compiled file.
The default is  constructed using filename and adding  a .elc extenstion
to it.  This  option exists to take care of cases  like ~/.gnus -- which
some people prefer to give their byte-compiled gnus customizations file.

It was  fun writing this  macro :)  If you want  to load some  file (say
~/.gnus) from  within another lisp function,  and ~/.gnus has  a call to
this macro, then the load form should be inclosed within a
(condition-case ...)  form.  Look at the way the macro makes a non-local
exit after loading the freshly byte-compiled file.  Recall that we don't
want the  entire file to  be evaled twice!   evaling it once  is painful
enough...   This non-local  exit shit  puts some  additional constraints
when we load  files containing this stuff... Since we  need to catch the
error  that will  be  thrown from  the  inner call  to  this macro,  the
invocation should be placed in a condition-case.  Enough said!"

  (let ((source (or (and missing-dot-el
			 filename)
		    (concat filename ".el")))
	(byte-file (or elc-file
		       (concat filename ".elc"))))
   (message "source file: %s" source)
   (message "byte-file : %s" byte-file)
    (if (file-newer-than-file-p source byte-file)
	(let ((mode-line-format 
	       (concat "*** PLEASE STANDBY: RECOMPILING " source)))
	  (save-excursion
	    (byte-compile-file source)
	    (message "%s recompiled --- reloading ..." source)
	    (load byte-file t t t)
	    (message filename " recompiled")
	    (setq init-file-debug t)
	    (signal 'my-non-local-exit-error "")
	    ))
      (message "Loading rest of stuff"))
    ))

;(macroexpand '(byte-compile-nonsense "~/.customs.emacs" t))

(defun add-file-list-to-list (list-sym names &optional expand-file-p)
  "Adds a list  of names to given list.  The first  argument should be a
list, as a symbol, to which will  be added all the names in the `names',
one at  a time using `add-to-list'.   If the optional  third argument is
non-nil, then the names  are all piped through `expand-file-name' before
being added."
  (mapcar (lambda (a)
	    (when (file-exists-p a)
	      (add-to-list list-sym (or (and expand-file-p
					     (expand-file-name a)
					a)))))
	    names))

;; Lifted with thanx from the Emacs sources... startup.el, I think.
(defun my-normal-top-level-add-subdirs-to-load-path ()
  "Add  all subdirectories  of current  directory to  `load-path'.  More
precisely,  this uses  only the  subdirectories whose  names  start with
letters or  digits; it excludes  any subdirectory named `RCS'  or `CVS',
and any subdirectory that contains a file named `.nosearch'."
  (let (dirs 
	attrs
	(pending (list default-directory)))
    ;; This loop does a breadth-first tree walk on DIR's subtree,
    ;; putting each subdir into DIRS as its contents are examined.
    (while pending
      (setq dirs (cons (car pending) dirs))
      (setq pending (cdr pending))
      (let ((contents (directory-files (car dirs)))
	    (default-directory (car dirs)))
	(while contents
	  (unless (member (car contents) '("." ".." "RCS" "CVS"))
	    (when (and (string-match "\\`[a-zA-Z0-9]" (car contents))
		       ;; Avoid doing a `stat' when it isn't necessary
		       ;; because that can cause trouble when an NFS server
		       ;; is down.
		       (not (string-match "\\.elc?\\'" (car contents)))
		       (file-directory-p (car contents)))
	      (let ((expanded (expand-file-name (car contents))))
		(unless (file-exists-p (expand-file-name ".nosearch"
							 expanded))
		  (setq pending (nconc pending (list expanded)))))))
	  (setq contents (cdr contents)))))
    (add-file-list-to-list 'load-path (nreverse dirs))))

;; Finally,  let's  use  the  above  function  to  setup  the  load-path
;; accordingly.  This, basically,  adds all subdirectories under ~/elisp
;; to  load-path recursively,  unless the  conditions enumerated  in the
;; comments above are met.   Commented out on 13-10-2001.  Basically, we
;; have a lot of arbit shit in our ~/elisp directory, like four versions
;; of gnus etc,  The code below simbly adds all  that shit to load-path;
;; Since adding  .nosearch files to all  seems like a bad  idea (well, I
;; was using  symlinks to  get around just  this problem) Looks  like we
;; need to do some more reorganizing of our source tree at the very least.

;; (let ((default-directory "~/elisp"))
;;   (my-normal-top-level-add-subdirs-to-load-path)) 

;; Setup   the   load   paths:   This   stuff  used   to   be   in   the
;; .mach-dep.customs.emacs file,  but I have decided to  maintain a very
;; similar source tree for the elisp packages across accounts.  Moreover
;; having non-existant paths in the  load-path does not affect thing too
;; bad.
(add-file-list-to-list 'load-path
		       '("~/elisp"
 			 "~/elisp/games"
			 "~/elisp/bbdb/lisp/"
			 "~/elisp/eieio/"
			 "~/elisp/semantic/"
			 "~/elisp/jde/lisp/"
 			 "~/elisp/gnus/lisp"
			 "~/elisp/tramp/lisp"
			 "~/elisp/w3m_el/lisp"
			 "~/elisp/Small1s"
			 "~/elisp/Large1s/auctex"
 			 "~/elisp/Large1s/bbdb/lisp"
 			 "~/elisp/Large1s/bbdb/bits"
			 "~/elisp/Large1s/bbdb/bits/bbdb-filters"
 			 "~/elisp/Large1s/dismal-1.4/"
 			 "~/elisp/Large1s/elib"
 			 "~/elisp/Large1s/gnus/lisp"
;;			 "~/elisp/Large1s/gnus/contrib/"
 			 "~/elisp/Large1s/gnuserv"
 			 "~/elisp/Large1s/mailcrypt/"
 			 "~/elisp/Large1s/ps-print/lisp"
			 "~/elisp/Large1s/w3m_el/lisp/"
			 "~/elisp/Large1s/supercite/")
 			t)

;; PCL-CVS is part of Emacs21.  Once we are really satisfied with
;; Emacs21, we would like to get rid of the following code.
(GNUEmacs-old
 (add-to-list 'load-path "~/elisp/Large1s/pcl-cvs/lisp"))

;; Set up the info path for the packages I installed.  This was also moved
;; from .mach-dep stuff for the reasons cited above.
(when (eq whereami 'hcl-nt)
  (setq Info-default-directory-list (list)))
(add-file-list-to-list 'Info-default-directory-list
		       '("~/elisp/info/" "~/info")
		       t)

;; Setup up some variables whose values will be set by the machine specific
;; initialization routines.

(defvar my-lpr-command "lpr"
  "Value of machine specific printing command.
This values is used to  initialize a bunch of print-related variables in
the  printing.el and ps-print.el  packages.  Hmm...  Having just  one of
these customization variables  may prove to be too  restrictive, but the
currently all the printers I have access to are postscript printers that
can print text as well, so for now there is no problem.")

(defvar my-printer-name "cesps"
  "Machine specific name of postscript printer.
This values is used to  initialize a bunch of print-related variables in
the  printing.el and ps-print.el  packages.  Hmm...  Having just  one of
these customization variables  may prove to be too  restrictive, but the
currently all the printers I have access to are postscript printers that
can print text as well, so for now there is no problem.")

(defvar my-printer-symbol (make-symbol my-printer-name)
 "Machine specific name of PS printer, as a symbol, rather than a string.")

;; Now, we load the machine dependent customisations.  This sets the load
;; paths and stuff.  Commented out because we have moved away from this
;; style of setup.
;; (if (file-exists-p "~/.mach-dep.customs.emacs")
;;     (progn
;;       (setq machine-dep-customs-exists t)
;;       (require  'mach-dep "~/.mach-dep.customs.emacs")
;;       (do-initial-machine-dependent-stuff))
;;   (prog2
;;       (message (concat "Could not find .mach-dep.customs.emacs.  "
;; 		       "some critical variables may be set wrong."))
;;       (setq machine-dep-customs-exists nil)))

;; This is the most important macro.  This is used throughout to load
;; libraries.
;; TODO:
;;	(a) will have to change load-library-carefully to take
;;          arguments to require.
(defmacro load-library-carefully (lib &optional initial-hook final-hook
				      fail-func)
  "Load `lib' with error checks.
This macro will attempt to load `lib' if present.  Without throwing an
error.

This macro is designed to make Emacs startup times fast - for a few
Emacs setups.  For example, at work, I do not have the complete set of
add-on packages installed, so there is really no point in looking for
those packages every time Emacs starts up.  This lookup is done at
byte-compile time.  And load library statements are issued (to the .elc
file) only for those that really exist.

The (optional) second and third arguments are hooks, which need to be
run before and after the library is loaded (if available)."

  (let* ((lib (eval lib))
	 (lib-name
	  (cond ((symbolp lib)
	       (symbol-name lib))
		(t lib)))
	 (ret-list '()))
    (if (locate-library lib-name)
	(progn
	  (when (eval final-hook)
	    (push `(funcall ,final-hook) ret-list))    

	    (if (symbolp lib)
		(push `(require ',lib nil t) ret-list)
	      (push `(load-library ,lib) ret-list))

	    (when (eval initial-hook)
	      (push `(funcall ,initial-hook) ret-list)))
      	    
      (progn
	(if (eval fail-func)
	    (push `(funcall ,fail-func) ret-list)
	  (message (concat "library " lib-name " not found dude.")))))
    
    (push 'progn ret-list)
    ret-list))


;; (defun load-library-carefully (lib &optional initial-hook final-hook
;; 				   fail-func)
;;   "Load `lib' with error checks.
;; This function loads lib if available., and just prints a message if that
;; library is not available.  You can provide a function name as the fourth
;; argument, and that function will be run instead.  This is useful if we
;; are loading a crucial library, and cannot continue without it.  The
;; (optional) second  and third arguments are  hooks, which need  to be run
;; before and after the library is loaded (if available)."
;; (let ((lib-name
;;        (cond ((symbolp lib)
;; 	      (symbol-name lib))
;; 	     ((stringp lib)
;; 			 lib))))
;;   (if (locate-library lib-name)
;;       (progn
;; 	(when initial-hook
;; 	  (progn
;; 	    (print initial-hook)
;; 	    (funcall initial-hook)))
;; 	(if (symbolp lib)	      
;; 	    (require lib)
;; 	  (load-library lib))
;; 	(when final-hook
;; 	  (progn
;; 	    (funcall final-hook)))
;; 	t)
;;     (prog2
;; 	(if fail-func
;; 	    (funcall fail-func)
;; 	  (message (concat "library " lib-name " not found dude.")))
;; 	nil))))

;;; Locale specific initialization customizations.

;; Here one would some site-specific customizations.  For e.g. for
;; windows-NT systems, we have to load in cygwin-mount.el and
;; stuff... and so on.

(when (or (eq whereami 'intel)
	  (eq whereami 'prodapt)
	  (eq whereami 'hcl-nt)
	  (eq system-type 'windows-nt))
  (load-library-carefully "cygwin-mount"
			  nil
			  (lambda ()
			    (cygwin-mount-activate)))

  (setq default-directory "~/")
  (setq default-buffer-file-coding-system 'undecided-unix))

(cond
 ((eq whereami 'hcl-nt)
  (setq my-lpr-command         "lpr"
	my-lpr-switches        (list "-d" "-Sprint.esl.cisco.com")
	my-printer-name-option "-P"
	my-printer-name        "codc1-3f-hp8"
	my-printer-symbol      (make-symbol my-printer-name)))

 ((eq whereami 'hcl-linux)
  (setq my-lpr-command "lpr"
	my-lpr-switches nil
	my-printer-name-option "-P"
        my-printer-name "codc1-3f-hp8"
;	my-printer-name "gps-na-4"
	my-printer-symbol (make-symbol my-printer-name)))
 
 ((eq whereami 'techm-blr)
  (setq my-lpr-command ""
	my-lpr-switches nil
	my-printer-name-option "-P"
        my-printer-name "//192.168.5.22/Blr-1stBldg3flr"
;	my-printer-name "gps-na-4"
	my-printer-symbol (make-symbol my-printer-name)))
 (t
  (setq my-lpr-command "lpr"
	my-lpr-switches nil
	my-printer-name-option "-P"
	my-printer-name ""
	my-printer-symbol (make-symbol my-printer-name))))


;;; Load up as many nifty libraries as humanly possible

;; load font-lock.  we set the global variable font-lock-set-now
;; accordingly.  We could have just given a final-hook function, but it
;; will get really big and unwieldy.  we can now do whatever we want
;; based on the value of this variable.  A lot of packages turn on/off
;; their font-lock capability depending on the state of other global
;; font-lock variables.  So, we would do well to load it first up.
(setq font-lock-maximum-decoration t)
(unless (featurep 'xemacs)
  (global-font-lock-mode t))
(turn-on-font-lock)
; (setq font-lock-support-mode 'lazy-lock-mode)

(load-library-carefully 'cc-cmds)

;; When we are using the sawmill window manager, let's load the sawmill
;; mode.  The idea is the call-process will return a non-zero value if a
;; sawmill session is not active.
;;(when (= (call-process "sawmill-client" nil nil nil "-e" "nil") 0)
;;  (load-library-carefully 'sawmill))

;; In GNU Emacs 21.1, the filladapt code was assimilated by the Emacs
;; continuum.  Using the old file with 21.1 causes some painful
;; failuers.
(GNUEmacs-old
 (condition-case err
     (require 'filladapt nil)
   (error nil)))

;; find-func.el is extremely fundu, simple library that allows you to
;; visit elisp source files for functions at point.  so if you are
;; wondering what a certain elisp function does, all you have to do is,
;; place your cursor on the function name, and type ESC-x
;; find-func-at-point, and find-func will open a new buffer that has the
;; file, and place point there!
(load-library-carefully 'find-func
			nil
			(lambda ()      
			  "Thought find-func that comes with Emacs
20.4 has the following function defined, the CS side has crappy shit
installed.  so I had to paste the following code from the cade side. "
			  (when (fboundp 'find-function-setup-keys)
			    (find-function-setup-keys))
			  (global-set-key [?\C-,] 'find-function-at-point)
			  (global-set-key [?\C-.] 'find-variable-at-point)))

;; setup recentf which will provide a list of recently visited buffers.
(GNUEmacs
 (load-library-carefully
  'recentf
  nil
  (lambda ()
    (recentf-mode t))
  (lambda ()
    (message (concat "recentf.el could not be found.  "
		     "Isnt this supposed to be part of Emacs?")))))

;; load my random-man package
(load-library-carefully 'random-man)

;; follow-dev.el is a library that allows the current buffer to be
;; selected just by moving the cursor without a need to click.
;; It does not load under XEmacs...
(unless (featurep 'xemacs)
  (load-library-carefully
   "follow-dev"
   nil
   (lambda ()
     (turn-on-follow-mouse)
     (setq follow-mouse-auto-raise nil))))

;; load w3.  w3 is the emacs based web browser... It also does not load
;; under XEmacs...  Maybe we have to build it specially for XEmacs...
;; (unless (featurep 'xemacs)
;;   (load-library-carefully 'w3))

;; require compile.  This is used in M-x compile stuff for the major
;; modes 
(load-library-carefully 'compile)

;; pcl-cvs -- the Emacs front end for CVS.  It is part of Emacs21.  Once
;; we are really satisfied with Emacs21, we would like to get rid of the
;; following code.
(GNUEmacs-old
 (load-library-carefully 'pcl-cvs
			 nil
			 (lambda ()
			   (load-library "pcl-cvs-startup"))))

;; load the fantastic ibuffer.el package (not part of standard Emacs) -
;; This package also has a dependency on the font-lock package (if you are
;; interested in colourful buffers, i.e.
;; I believe there are some .elc level incompatibilities between
;; GNUEmacs21 and XEmacs...  Oh well...

(GNUEmacs
 (load-library-carefully
  'ibuffer
  nil
  (lambda ()
    (global-set-key [?\C-x ?\C-b] 'ibuffer)
    (setq ibuffer-directory-abbrev-alist
	  '(("/nfs/flux/cmplrs-src/src_release"."MIPS")
	    ("/home/cs/handin/cs5470/tests"."CTESTS")
	    ("/home/cs/handin/cs5470/handin"."HANDIN")
	    ("/a/home/cs/handin/cs5470/tests"."CTESTS")
	    ("/a/home/cs/handin/cs5470/handin"."HANDIN")))
    (setq ibuffer-formats
	  '((mark modified read-only " "
		  (name 16 16) " " (size 6 -1 :right)
		  " " (mode 16 16) " " filename)
	    (mark modified read-only " " (name 30 30)
		  " " filename)
	    (mark modified read-only " "
		  (name 16 -1) " " (size 6 -1 :right)
		  " " (mode 16 16) " " filename))))))

;; Just do a require gnus..  No hooks here ;-) Look at ~/.gnus for a truck
;; load of customization.  These lines of code are necessary, even
;; though all versions and flavours of Emacs come with a bare set of
;; autoloads to allow us to do a M-x gnus RET kinda things.  However if
;; we want to, say, send a mail without actually startin gnus, and want
;; to use message-mode... stuff like that.  Note, however, that since
;; gnus is not running, some things just might not work.  For example,
;; with the following setup alone in a .emacs, one can do a C-x m to get
;; into a very much Gnus-ish message mode buffer, complete with your GCC
;; stuff and so on.  But the GCC itself will not go anywhere...  But it
;; might be worth something :-)
;;
;; Fri Sep 12 04:01:29 2003 - commented out to improve emacs startup
;; time.  gnus is not relevant when I use Emacs on San Jose cisco
;; servers, for e.g.
;;
;; (require 'gnus-msg)
;; (when (file-exists-p (expand-file-name "~/.gnus"))
;;   (condition-case err
;;       (load-file "~/.gnus")
;;     (my-errors nil)))
;; (setq mail-user-agent 'gnus-user-agent)

;; (add-hook 'mail-setup-hook 'mail-abbrevs-setup)
(add-hook 'mail-mode-hook 'mail-abbrevs-setup)

;; bbdb can do some really cool stuff.  TODO: Put some stuff in
;; bbdb-auto-notes-alist -- in particular, setup the "company" field
;; automatically -- this needs some work and careful thinking.
(defun snarf-company-name (str)
  (if (not (and (boundp 'gnus-newsgroup-name)
		gnus-newsgroup-name))
      ""
    (if (boundp 'local-company)
	local-company
      (if (string-match "[^:]*:\\(.*\\)" gnus-newsgroup-name)
	  (let ((a (match-string 1 gnus-newsgroup-name)))
	    (if (or (string= "default" a)
		    (string= "Default" a))
		""
	      a))
	gnus-newsgroup-name))))

(defun bbdb-stuff ()
;  (bbdb-initialize 'gnus 'rmail 'w3 'sendmail)
;;  (require 'bbdb-gnus)
  (bbdb-initialize 'gnus 'rmail 'sendmail)
  (add-hook 'mail-setup-hook 'bbdb-insinuate-sendmail)
  (add-hook 'mail-setup-hook 'bbdb-define-all-aliases)  
  (add-hook 'message-setup-hook 'bbdb-define-all-aliases)
  (setq bbdb-offer-save 'no-thanks)
  (add-hook 'bbdb-notice-hook 'bbdb-auto-notes-hook)

  ;; do something useful with the bbdb-auto-notes-alist
  (setq bbdb-auto-notes-alist
	'(("From" (".*" company snarf-company-name ))
	  ("user-agent" (".*" interface 0))
	  ("X-Mailer" (".*" interface 0))
	  ("x-newsreader" (".*" interface 0))
	  ("newsgroups" ("\\([^,]*\\),?" posted-to "\\1"))
	  ("Xref" ("\\b[^ ]+:[0-9]+.*" seen-in))))
  (put 'seen-in 'field-separator "; ")

  (setq bbdb-send-mail-style 'message)
  (setq bbdb-canonical-hosts
	(concat "cs\\.cmu\\.edu\\|cs\\.utah\\.edu\\|"
		"eng\\.utah\\.edu"))
  t)

;; the following lifted from Karl Keinpaste <karl@charcoal.com> 's post on
;; g.e.g.  Some of it appears new - look into sometime.

;; (require 'bbdb)
;; (require 'bbdb-hooks)
;; (require 'message)
;; (add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
;; (add-hook 'message-setup-hook 'bbdb-define-all-aliases)
;; (bbdb-initialize 'gnus 'message)
;; (setq bbdb-offer-save 'always
;;       bbdb-notice-hook 'bbdb-auto-notes-hook
;;       bbdb-pop-up-target-lines 9
;;       bbdb-auto-notes-alist
;;       '(("user-agent" (".*" interface 0 t))
;; 	("x-mailer" (".*" interface 0 t))
;; 	("x-newsreader" (".*" interface 0 t))
;; 	("newsgroups" ("\\([^,]*\\),?" posted-to "\\1" t))
;; 	("xref" ("\\b[^ ]+:[0-9]+.*" seen-in 0))))
;; (put 'seen-in 'field-separator "; ")

;; BBDB related customisations
(load-library-carefully 'bbdb
 			nil
 			'bbdb-stuff)

;; mailcrypt is a front end for PGP/GnuPG.  I spent a lot of time setting
;; up the damn thing, acquiring a key pair, submitting my public key to key
;; servers, and all that crap - but I have not used it since (no one to
;; communicate with - Rajiv, if you read this, please be informed that you
;; suck big time).  Maybe one day I will be the chief IT officer for RAW,
;; and this piece of software will come in handy then.  So, lets keep
;; practising by sending one encrypted/signed message to self every week.
;; (unless (eq 'windows-nt system-type)
(load-library-carefully 'mailcrypt
			nil
			(lambda ()
			  (let ((gpg-p
				 (eq (shell-command
				      "gpg --version > /dev/null")
				     0)))
			    (if gpg-p
				(mc-setversion "gpg")
			      (mc-setversion "5.0"))
			    (add-hook 'mail-mode-hook
				      'mc-install-write-mode))))

;; Load in Eric Eide's cool package.  It allows us to scroll through the
;; buffer while keeping the cursor stationary.  Good bye the repetitive
;; C-v C-l sequences...  It provides much more functionality than this -
;; work on it when time permits
(load-library-carefully 'scroll-in-place)

;; Emacs can handle gzipped files automatically - jka-compr is part of
;; standard Emacs distribution.  And there have been a few changes in
;; the versions shipped with 20.7 and 21

(GNUEmacs21
 (auto-compression-mode))

(GNUEmacs-old
 (require 'jka-compr))

;; Load the auc-tex package -- Has very nifty features for editing LaTeX
;; documents -- Don't really know why I commented out the stuff :)
(load-library-carefully 'tex-site
			nil
			(lambda ()
			  (setq reftex-enable-partial-scans t
				reftex-save-parse-info t
				reftex-use-multiple-selection-buffers t
				reftex-plug-into-AUCTeX t)))

;; ;; Load our own frio-asm mode, and tell Emacs to use it to edit _all_
;; ;; assembly programs (ending in .s) - used only while at Intel.
;; (load-library-carefully 'frio-asm
;; 			nil
;; 			(lambda ()
;; 			  (setq auto-mode-alist
;; 				(append
;; 				 '(("\\.s$" . frio-asm-mode))
;; 				 '(("\\.S$" . frio-asm-mode))
;; 				 auto-mode-alist))))


;; browse-cltl2.el is a nice little package that allows us to browse Guy
;; Steele's monumental book "Common Lisp" or some such :)  I have it
;; installed locally.  You can either install it locally or browse it
;; off the net from the CMU website or one of its mirrors.
(defun ilisp-browse-cltl2-after-load-hook ()
  (autoload 'cltl2-view-function-definition "browse-cltl2")
  (autoload 'cltl2-view-index "browse-cltl2")
  (autoload 'cltl2-lisp-mode-install "browse-cltl2")
  (add-hook 'lisp-mode-hook 'cltl2-lisp-mode-install)
  (add-hook 'ilisp-mode-hook 'cltl2-lisp-mode-install))

;; We have to set this variable _before_ we load it...  kind of
;; screwey... Oh well... :)
(defvar *cltl2-local-file-pos* (expand-file-name "~/elisp/info/cltl/")
  "A directory where the CLtl2 can be found. Note that this assumes
 to be the top-level of the directory structure which should be the
 same as in the hypertext version as provided by the CMU AI Repository.
 Defaults to /usr/doc/html/cltl/ Note the / at the end.")

;; (load-library-carefully "browse-cltl2"
;; 			nil
;; 			'ilisp-browse-cltl2-after-load-hook)


;; Load and  start gnuserv if available, otherwise  start the standard
;; Emacs server  -- gnuserv is not  distributed with GNU  Emacs, so we
;; need to put it inside a condition-case...
(condition-case err
    (if (require 'gnuserv)
	(gnuserv-start)
      (server-start))
  (error nil))

;; Tramp - edit remote files over ssh
(load-library-carefully
 'tramp
 nil
 (lambda ()
   (add-to-list 'Info-default-directory-list
		"~/elisp/tramp/texi")
   (setq tramp-verbose 10)
   (setq tramp-debug-buffer t)
   (setq tramp-default-method "putty")
   (add-to-list 'tramp-methods
		'("putty"
		 (tramp-connection-function tramp-open-connection-rsh)
		 (tramp-rsh-program "ssh")
		 (tramp-rcp-program "scp")
		 (tramp-remote-sh "/bin/bash")
		 (tramp-rsh-args ("-e" "none"))
		 (tramp-rcp-args nil)
		 (tramp-rcp-keep-date-arg "-p")
		 (tramp-su-program nil)
		 (tramp-su-args nil)
		 (tramp-encoding-command nil)
		 (tramp-decoding-command nil)
		 (tramp-encoding-function nil)
		 (tramp-decoding-function nil)
		 (tramp-telnet-program nil)
		 (tramp-telnet-args nil)))))

;; iswitchb is an awesome replacement for C-x b.  Load it up and ensoy
(when (fboundp 'iswitchb-mode)
  (iswitchb-mode t))

;; Load up EUDC, so we can interact with the Cisco LDAP directory.
(load-library-carefully
 'eudc
 nil
 (lambda ()
   (eval-after-load
       "message"
     '(define-key message-mode-map [(control ?c)
				    (tab)]
	'eudc-expand-inline))
   (setq ldap-default-host "ldap.cisco.com"
	 ldap-host-parameters-alist '(("ldap.cisco.com" base "o=cisco.com"))
	 eudc-server "ldap.cisco.com"
	 ldap-default-base "ou=active,ou=employees,ou=people,o=cisco.com")))

;; Some parts of the eudc stuff appears broken... atleast as used with
;; the cisco setup.  The following is an attempt to fix things up a
;; little.

(when (fboundp 'eudc-get-email)

  ;; With the -x flag, we tell the `ldapsearch' program to use "simple"
  ;; authentication (whatever that is) and not SASL... which creates
  ;; problems.
  (setq ldap-ldapsearch-args '("-x"))

  ;; 1. For some reason the format of the returned results appears
  ;;    different from what eudc expects.  So we simply re-define the
  ;;    following two functions so that it works "right"
  ;; 2. eudc-expand-inline works right and does not need fixing
  ;; 3. The "name" parameter used below is matched with the surname
  ;;    field in the ldap.  This is simply too restrictive, I say.  We
  ;;    got to figure out how to match the name against the "cn" field.

  (defun eudc-get-email (name)
    "Get the email field of NAME from the directory server."
    (interactive "sName: ")
    (or eudc-server
	(call-interactively 'eudc-set-server))
    (let ((result (eudc-query (list (cons 'name name)) '(email)))
	  email)
      (if (null (cdr result))
	  ;;	(setq email (cdaar result))
	  (setq email (cdr (car (cdr (car result)))))
	(error "Multiple match. Use the query form"))
      (if (interactive-p)
	  (if email
	      (message "Mail = %s" email)
	    (error "No record matching %s" name)))
      email))
  
  (defun eudc-get-phone (name)
    "Get the phone field of NAME from the directory server."
    (interactive "sName: ")
    (or eudc-server
	(call-interactively 'eudc-set-server))
    (let ((result (eudc-query (list (cons 'name name)) '(phone)))
	  phone)
      (if (null (cdr result)) 
	  ;;	(setq phone (eudc-cdaar result))
	  (setq phone (cdr (car (cdr (car result)))))
	(error "Multiple match. Use the query form"))
      (if (interactive-p)
	  (if phone
	      (message "%s" phone)
	    (error "No record matching %s" name)))
      phone)))


;;; Keyboard customisations

(defvar karra-office-address
  "Sriram Karra
School of Computing
Rm 3190, Merrill Engineering Building
50 S, Central Campus Dr.
University of Utah
Salt Lake City, UT - 84112. ")

(defvar karra-home-address
  "Sriram Karra
517 South, 1100 East
Apt #5
Salt Lake City, UT - 84102. "
    "home address")

(defconst months-alist
  '(( 1 . "January")
    ( 2 . "February")
    ( 3 . "March")
    ( 4 . "April")
    ( 5 . "May")
    ( 6 . "June")
    ( 7 . "July")
    ( 8 . "August")
    ( 9 . "September")
    (10 . "October")
    (11 . "November")
    (12 . "December")))

(defun month-num-to-string (num)
  (cdr (assoc num months-alist)))

(defun current-month ()
  (interactive)
  (cadr (cddr (cdr (decode-time)))))

(defun current-year ()
  (interactive)
  (cadr (cddr (cddr (decode-time)))))

(defmacro c-cvs-header ()
  `(concat "/*------------------------------------------------------------------
 * " (file-name-nondirectory (buffer-file-name)) "
 *  
 * " (month-num-to-string (current-month)) (format " %d" (current-year))
 ", Sriram Karra
 *
 * Copyright (c) " (format "%d" (current-year)) " by cisco Systems, Inc.
 * All rights reserved.
 *------------------------------------------------------------------
 */"))

(defvar hash-cvs-header
  "##
## Sriram Karra
##
## $Id: .customs.emacs,v 1.13 2004/11/05 09:10:59 karra Exp $
##"
  "hash cvs address")

(defun insert-office-address ()
  (interactive)
    "Inserts my office address at point.  This value is taken from the
variable--`karra-office-address'"
  (insert karra-office-address))

(defun insert-home-address ()
  (interactive)
    "Inserts my my address at point.  This value is taken from the
variable--`karra-home-address'"
  (insert karra-home-address))

(defun insert-c-cvs-header ()
  (interactive)
  (insert (c-cvs-header)))

(defun insert-hash-cvs-header ()
  (interactive)
  (insert hash-cvs-header))

(defun kill-to-bob ()
  "Kill from here to beginning of buffer."
  (interactive)
  (delete-region (point) (point-min)))

(defun kill-to-eob ()
  "Kill from here to end of buffer."
  (interactive)
  (delete-region (point) (point-max)))

(defvar my-time-format-string
  "%a %h %d %T %Z %Y")

(defun insert-time ()
  (interactive)
  (let ((s (format-time-string my-time-format-string)))
    (insert s)))

(defun insert-sig ()
  (interactive)
  (insert "\nThanks,\n-Sriram\n"))

(defun insert-time-and-del ()
  (interactive)
  (let ((s (format-time-string my-time-format-string)))
    (delete-char (length s))
    (insert (format-time-string my-time-format-string))))

;; Some global key definitions
(global-set-key "\M-g"			'goto-line)
(global-set-key [(f2)]			'info)
(global-set-key [(home)]		'beginning-of-line)
(global-set-key [(end)]			'end-of-line)
(global-set-key [(control home)]	'beginning-of-buffer)
(global-set-key [(control end)]		'end-of-buffer)
;(global-set-key [(C-M-home)]	'kill-to-bob)
;(global-set-key [(C-M-end)]	'kill-to-eob)
;(global-set-key [(delete)]	'delete-char)
;(global-set-key [(delete)]	'backward-delete-char-untabify)
(global-set-key [(f3)]		'insert-office-address)
(global-set-key [(f4)]		'insert-home-address)
(global-set-key [(f5)]		'insert-c-cvs-header)
(global-set-key [(f6)]		'insert-hash-cvs-header)
(global-set-key [(f7)]          'insert-time)
(global-set-key [(f8)]          'insert-time-and-del)
(global-set-key [(f9)]		'revert-buffer)
(global-set-key [(f10)]		'insert-sig)
(global-set-key [(control f1)]		'mail-interactive-insert-alias)

;;; Colors & font-lock related stuff.

;; face-list is a very convenient package to customize "faces".  A
;; face is an emacs term for a group of text properties like font,
;; bold/underline/italics etc.  This package helps in easy
;; customization of these
;(load-library-carefully 'face-list)

;; set the default colors for the foreground and background.  note
;; that this

(defun setup-colors-old-way ()  
  (unless (featurep 'xemacs)
    (set-cursor-color "red")
    (set-mouse-color "brown"))

  ;; set colors
  (if window-system
      (progn
	(set-background-color "Black")
	(set-foreground-color "Tan")
	(set-cursor-color "grey"))
; The font setting should be done right in .Xdefaults
;	(set-default-font
;	 "-misc-fixed-medium-r-semicondensed-*-*-100-*-*-c-*-iso8859-1"))
    (progn 
      (set-face-foreground 'default          "black")
      (set-face-background 'default          "beige")))

  (set-face-background 'modeline         "gray")
  (set-face-foreground 'modeline         "red")

  (if (featurep 'xemacs)
      (prog2
	  (set-face-foreground 'zmacs-region	"ForestGreen")
	  (set-face-background 'zmacs-region	"white"))
    (prog2
	(set-face-foreground 'region           "ForestGreen")
	(set-face-background 'region           "white")))
  
  ;; see m-x list-faces-display too

  (set-face-foreground 'italic "darkgoldenrod")
  (set-face-foreground 'bold "red")  
  (set-face-foreground font-lock-comment-face "red")
  (set-face-foreground font-lock-string-face "cornsilk1")
  (set-face-foreground font-lock-function-name-face "brown")
  (set-face-foreground font-lock-keyword-face "mediumturquoise")
  (set-face-foreground font-lock-variable-name-face "firebrick")
  (set-face-foreground font-lock-reference-face "red3")
  (set-face-foreground font-lock-string-face "green4")
  (set-face-foreground font-lock-variable-name-face "orangered")
  (set-face-foreground font-lock-type-face "lightgreen")

  (defmacro customize-gnus-colors ()
    (set-face-foreground 'message-separator-face "beige")
    (set-face-foreground 'message-header-to-face "seagreen1")
    (set-face-foreground 'message-header-subject-face "darkolivegreen1")
    (set-face-foreground 'message-header-newsgroups-face "lightgreen"))
      
;  (make-face-unitalic font-lock-string-face nil)
;  (set-face-underline-p font-lock-string-face nil)
;  (make-face-italic font-lock-comment-face nil)

  (unless (featurep 'xemacs)
    (set-face-foreground font-lock-warning-face "Red")	
    (set-face-foreground font-lock-constant-face "deepskyblue")
    (set-face-foreground font-lock-builtin-face "Orchid")))

;; The following is the same info as above in the form of a
;; "color-theme".
(defun color-theme-karra ()
  "Color theme by Sriram Karra, created 2000-11-22.
This theme has black background and pleasant foreground colors."  

  (interactive)
  (color-theme-install
   `(color-theme-karra
     ((background-toolbar-color . "#cf3ccf3ccf3c")
      (border-color . "black")
      (bottom-toolbar-shadow-color . "#79e77df779e7")
      (cursor-color . "red")
      (mouse-color . "brown")
      (top-toolbar-shadow-color . "#fffffbeeffff"))
     ((Man-overstrike-face . bold)
      (Man-underline-face . underline)
      (goto-address-mail-face . italic)
      (goto-address-mail-mouse-face . secondary-selection)
      (goto-address-url-face . bold)
      (goto-address-url-mouse-face . highlight)
      (list-matching-lines-face . bold)
      (view-highlight-face . highlight))
    ,(when window-system
       '(default ((t (:background "white" :foreground "black")))))
    (blue ((t (:foreground "blue"))))
    (bold ((t (:bold t :foreground "red"))))
    (bold-italic ((t (:italic t :bold t))))
    (border-glyph ((t (nil))))
    (calendar-today-face ((t (:underline t))))
    (custom-button-face ((t (:bold t))))
    (custom-changed-face ((t (:background "blue" :foreground "white"))))
    (custom-documentation-face ((t (nil))))
    (custom-face-tag-face ((t (:underline t))))
    (custom-group-tag-face ((t (:underline t :foreground "blue"))))
    (custom-group-tag-face-1 ((t (:underline t :foreground "red"))))
    (custom-invalid-face ((t (:background "red" :foreground "yellow"))))
    (custom-modified-face ((t (:background "blue" :foreground "white"))))
    (custom-rogue-face ((t (:background "black" :foreground "pink"))))
    (custom-saved-face ((t (:underline t))))
    (custom-set-face ((t (:background "white" :foreground "blue"))))
    (custom-state-face ((t (:foreground "dark green"))))
    (custom-variable-button-face ((t (:underline t :bold t))))
    (custom-variable-tag-face ((t (:underline t :foreground "blue"))))
    (cvs-handled-face ((t (:foreground "medium turquoise"))))    
    (info-xref ((t (:bold t :foreground "firebrick"))))
    (diary-face ((t (:foreground "red"))))
    (font-lock-builtin-face ((t (:foreground "Orchid"))))
    (font-lock-comment-face ((t (:foreground "red"))))
    (font-lock-constant-face ((t (:foreground "deepskyblue"))))
    (font-lock-doc-string-face ((t (:foreground "green4"))))
    (font-lock-function-name-face ((t (:bold t :foreground "brown"))))
    (font-lock-keyword-face ((t (:bold t :foreground "medium turquoise"))))
    (font-lock-preprocessor-face ((t (:foreground "blue3"))))
    (font-lock-reference-face ((t (:foreground "red3"))))
    (font-lock-string-face ((t (:foreground "green4"))))
    (font-lock-type-face ((t (:foreground "blue4"))))
    (font-lock-variable-face ((t (:foreground "firebrick"))))
    (font-lock-variable-name-face ((t (:foreground "orangered"))))
    (font-lock-warning-face ((t (:bold t :foreground "Red"))))
    (gnus-cite-attribution-face ((t (:italic t))))
    (gnus-cite-face-1 ((t (:foreground "green4"))))
    (gnus-cite-face-10 ((t (:foreground "medium purple"))))
    (gnus-cite-face-11 ((t (:foreground "turquoise"))))
    (gnus-cite-face-2 ((t (:foreground "firebrick"))))
    (gnus-cite-face-3 ((t (:foreground "orangered"))))
    (gnus-cite-face-4 ((t (:foreground "dark goldenrod"))))
    (gnus-cite-face-5 ((t (:foreground "dark khaki"))))
    (gnus-cite-face-6 ((t (:foreground "dark violet"))))
    (gnus-cite-face-7 ((t (:foreground "SteelBlue4"))))
    (gnus-cite-face-8 ((t (:foreground "magenta"))))
    (gnus-cite-face-9 ((t (:foreground "violet"))))
    (gnus-emphasis-bold ((t (:bold t))))
    (gnus-emphasis-bold-italic ((t (:bold t :italic t))))
    (gnus-emphasis-italic ((t (:italic t))))
    (gnus-emphasis-underline ((t (:underline t))))
    (gnus-emphasis-underline-bold ((t (:bold t :underline t))))
    (gnus-emphasis-underline-bold-italic
     ((t (:bold t :italic t :underline t))))
    (gnus-emphasis-underline-italic ((t (:italic t :underline t))))
    (gnus-group-mail-1-empty-face ((t (:foreground "DeepPink3"))))
    (gnus-group-mail-1-face ((t (:foreground "DeepPink3" :bold t))))
    (gnus-group-mail-2-empty-face ((t (:foreground "HotPink3"))))
    (gnus-group-mail-2-face ((t (:foreground "HotPink3" :bold t))))
    (gnus-group-mail-3-empty-face ((t (:foreground "magenta4"))))
    (gnus-group-mail-3-face ((t (:foreground "magenta4" :bold t))))
    (gnus-group-mail-low-empty-face ((t (:foreground "DeepPink4"))))
    (gnus-group-mail-low-face ((t (:foreground "DeepPink4" :bold t))))
    (gnus-group-news-1-empty-face ((t (:foreground "ForestGreen"))))
    (gnus-group-news-1-face ((t (:foreground "ForestGreen" :bold t))))
    (gnus-group-news-2-empty-face ((t (:foreground "CadetBlue4"))))
    (gnus-group-news-2-face ((t (:foreground "CadetBlue4" :bold t))))
    (gnus-group-news-3-empty-face ((t (nil))))
    (gnus-group-news-3-face ((t (:bold t))))
    (gnus-group-news-low-empty-face ((t (:foreground "DarkGreen"))))
    (gnus-group-news-low-face ((t (:foreground "DarkGreen" :bold t))))
    (gnus-header-content-face ((t (:foreground "blue4" :italic t))))
    (gnus-header-from-face ((t (:foreground "blue4" :bold t))))
    (gnus-header-name-face ((t (:foreground "maroon"))))
    (gnus-header-newsgroups-face ((t (:foreground "darkturquoise" :italic t))))
    (gnus-header-subject-face ((t (:foreground "red" :bold t))))
    (gnus-signature-face ((t (:italic t :foreground "red"))))
    (gnus-splash-face ((t (:foreground "ForestGreen"))))
    (gnus-summary-cancelled-face
     ((t (:foreground "yellow" :background "black"))))
    (gnus-summary-high-ancient-face ((t (:foreground "RoyalBlue" :bold t))))
    (gnus-summary-high-read-face ((t (:foreground "DarkGreen" :bold t))))
    (gnus-summary-high-ticked-face ((t (:foreground "firebrick" :bold t))))
    (gnus-summary-high-unread-face ((t (:bold t))))
    (gnus-summary-low-ancient-face ((t (:foreground "RoyalBlue" :italic t))))
    (gnus-summary-low-read-face ((t (:foreground "DarkGreen" :italic t))))
    (gnus-summary-low-ticked-face ((t (:foreground "firebrick" :italic t))))
    (gnus-summary-low-unread-face ((t (:italic t))))
    (gnus-summary-normal-ancient-face ((t (:foreground "RoyalBlue"))))
    (gnus-summary-normal-read-face ((t (:foreground "DarkGreen"))))
    (gnus-summary-normal-ticked-face ((t (:foreground "firebrick"))))
    (gnus-summary-normal-unread-face ((t (nil))))
    (gnus-summary-selected-face ((t (:underline t :foreground "blue3"))))
    (green ((t (:foreground "green"))))
    (gui-button-face ((t (:background "grey75" :foreground "black"))))
    (gui-element ((t (:background "Gray80"))))
    (highlight ((t (:background "darkseagreen2"))))
    (holiday-face ((t (:background "pink"))))
    (ibuffer-marked-face ((t (:foreground "darkgoldenrod"))))
    (isearch ((t (:background "paleturquoise"))))
    (italic ((t (:italic t :foreground "darkgoldenrod"))))
    (left-margin ((t (nil))))
    (list-mode-item-selected ((t (:background "gray68"))))
    (modeline ((t (:background "red" :foreground "gray" :inverse-video t))))
    (modeline-buffer-id ((t (:background "Gray80" :foreground "blue4"))))
    (modeline-mousable ((t (:background "Gray80" :foreground "firebrick"))))
    (modeline-mousable-minor-mode
     ((t (:background "Gray80" :foreground "green4"))))
    (nil ((t (nil))))
    (pointer ((t (nil))))
    (primary-selection ((t (:background "gray65"))))
    (red ((t (:foreground "red"))))
    (region ((t (:background "white" :foreground "ForestGreen"))))
    (right-margin ((t (nil))))
    (rmime-arrow-face ((t (:foreground "blue2"))))
    (rmime-markup-face ((t (:foreground "blue"))))
    (secondary-selection ((t (:background "paleturquoise"))))
    (text-cursor ((t (:background "Red3" :foreground "gray80"))))
    (toolbar ((t (:background "Gray80"))))
    (underline ((t (:underline t))))
    (vertical-divider ((t (:background "Gray80"))))
    (widget-button-face ((t (:bold t))))
    (widget-button-pressed-face ((t (:foreground "red"))))
    (widget-documentation-face ((t (:foreground "dark green"))))
    (widget-field-face ((t (:background "gray85"))))
    (widget-inactive-face ((t (:foreground "dim gray"))))
    (widget-single-line-field-face ((t (:background "gray85"))))
    (yellow ((t (:foreground "yellow"))))
    (zmacs-region ((t (:background "gray65")))))))

(load-library-carefully
 "color-theme"
 nil
 (lambda ()
   (add-to-list
    'color-themes
    '(color-theme-karra
      "Karra"
      "Sriram Karra <karra@cs.utah.edu>"))
   (color-theme-karra))
 (lambda ()
   (message
    "color-theme.el(c) not found in your load-path.  Setting up old way.")
   (setup-colors-old-way)))

(load-library-carefully "boxquote"
			nil
			(lambda ()
			  (setq boxquote-top-corner "/"
				boxquote-bottom-corner "\\"))
			nil)

;;; Mail related stuff: most of it is now in ~/.gnus

;; Sometimes the email address goes out in a ugle karra@famine.cs.utah.edu
;; and other such nonsense.  Since I keep using different machines, people
;; who have something like bbdb running, and receive my mails/posts will be
;; pained no end.  Setting the following variables takes care of this.
;; NOTE: bbdb has a variable called bbdb-canonical-hosts which will take
;; care of this... BUT...
(setq user-full-name "Sriram Karra")

(cond
 ((or (eq whereami 'hcl-linux)
      (eq whereami 'hcl-nt))
  (setq user-mail-address "skarra@cisco.com"
	message-user-organization "HCL Technologies, Cisco ODC"))

 ((or (eq whereami 'intel-home)
      (eq whereami 'intel-office))
  (setq user-mail-address "sriram.karra@intel.com"
	message-user-organization "Intel Corp."))
 
 (t
  (setq user-mail-address "karra@shakti.homelinux.net"
	message-user-organization "The Klingon High Council")))

;; ;; rmail customisation - Might just get rid of all this sometime.
;; ;; Hmm... We are getting better and better at using Gnus... Yeah, very
;; ;; shortly will get rid of all of this Rmail customizations.
;; (setq rmail-delete-after-output t)

;; ;; in RMAIL replying just to the From: guy is a pain, because by
;; ;; default everyone gets the reply.  The following binds 'r' to reply
;; ;; just to the sender and 'R' to everyone
;; (defun rmail-reply-no-cc ()
;;   "Reply without copying the CC:"
;;   (interactive) (rmail-reply t))

;; (defun rmail-summary-reply-no-cc ()
;;   "Reply without copying the CC:"
;;   (interactive) (rmail-summary-reply t))

;; (add-hook 'rmail-mode-hook
;;           (lambda()
;; 	    (define-key rmail-mode-map "r" 'rmail-reply-no-cc)
;; 	    (define-key rmail-mode-map "R" 'rmail-reply)
;;  	    (define-key rmail-mode-map "F" 'rmail-block-sender)))

;; (add-hook 'rmail-summary-mode-hook
;;           (lambda()
;; 	    (define-key rmail-summary-mode-map "r"
;; 	      'rmail-summary-reply-no-cc)
;; 	    (define-key rmail-summary-mode-map "R" 'rmail-summary-reply)
;;  	    (define-key rmail-summary-mode-map "F" 'rmail-block-sender)))

;; (add-hook 'rmail-reply-hook
;; 	  (lambda()
;; 	    (mail-yank-original 7)
;; 	    (mail-fill-yanked-message nil)
;; 	    (mail-text)
;; 	    (mail-signature nil)))

;;; Major-mode stuff.

;; This is how emacs tells the file type by the file suffix : a lot of this
;; stuff is the default behaviour, but it has been here for a long time, so
;; I dont have the heart to nuke it.
(setq auto-mode-alist
      (append '(("\\.obj$" . lisp-mode))
              '(("\\.st$"  . smalltalk-mode))
              '(("\\.cs$"  . indented-text-mode))
              '(("\\.icc$" . c++-mode))
	      '(("\\.l$"   . c-mode))
	      '(("\\.y$"   . c-mode))
	      '(("\\.ml$"  . sml-mode))
	      '(("\\.cshrc$" . shell-script-mode))
	      '(("\\.pl$"  . cperl-mode))
	      '(("\\.ics$"  . ical-mode))
	      '(("/usr/src/linux.*/.*\\.[ch]$" . linux-c-mode))
              auto-mode-alist))

;; When the first line of a file has somehting lie
;; #!/usr/local/bin/perl or something, Emacs automatically goes into a
;; certain mode whichit identifies by looking up
;; interpreter-mode-alist.  the default for perl is perl-mode. 
(setq interpreter-mode-alist
      (append '(("perl"    . cperl-mode))
	      interpreter-mode-alist))

;; This function is used in various programming language mode hooks below.
;; It does indentation after every newline when writing a program.  We also
;; want to enable auto-fill in the various programming languages.
(defun general-prog-mode-hook ()
  "Bind Return to `newline-and-indent' in the local keymap."
  (local-set-key "\C-m" 'newline-and-indent)
  (turn-on-auto-fill)
  (setq fill-column 78)
  (local-set-key [?\C-c ?\C-c] 'comment-region)
  (when (fboundp 'filladapt-mode)
    (filladapt-mode t)))

;; Tell Emacs to use the function above in certain editing modes.
(add-hook 'lisp-mode-hook             (function general-prog-mode-hook))
(add-hook 'emacs-lisp-mode-hook       (function general-prog-mode-hook))
(add-hook 'lisp-interaction-mode-hook (function general-prog-mode-hook))
(add-hook 'scheme-mode-hook           (function general-prog-mode-hook))
(add-hook 'c-mode-hook                (function general-prog-mode-hook))
(add-hook 'java-mode-hook             (function general-prog-mode-hook))
(add-hook 'c++-mode-hook              (function general-prog-mode-hook))
(add-hook 'perl-mode-hook             (function general-prog-mode-hook))
(add-hook 'cperl-mode-hook            (function general-prog-mode-hook))
(add-hook 'python-mode-hook           (function general-prog-mode-hook))

;; Emacs Lisp libraries mostly contain some general pattern easily
;; visible in terms of Outlines.k  Let us turn on outline minor mode

(add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)

;; Taken from /usr/src/linux/Documentation/CodingStyle
(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (c-set-style "linux"))

;; We can further tweak CC Mode, which handles all the C-like languages (C,
;; C++, Java, Obj-C, Pascal etc.)  Here, we define our own c-style for
;; editing C-like code.  The default is `gnu' style, which was kind of good
;; for a while, but I have recently started disliking its c-basic-offset
;; value of '2' - kinda too small.  Also most default styles do not have
;; anything meanigful in c-comment-continuation-stars; and so on.  so, it
;; is time to start one of our own to satisfy every small whim of ours
;; :)  NOTE: Some time between GNUEmacs 20.7 -> GNUEmacs 21.1,
;; c-comment-continuation-starts became obsolete...
(defconst my-c-style
  '((c-basic-offset		. 4)
    (c-tab-always-indent	. t)
    (c-comment-only-line-offset . 0)
    (c-hanging-braces-alist     . ((substatement-open after)
				   (brace-list-open)
				   (block-close c-snug-do-while)))
    (c-comment-continuation-stars . "* ")
    (c-block-comment-prefix       . "* ")
    (c-hanging-comment-ender-p  . nil)
    (c-special-indent-hook	. c-gnu-impose-minimum)    

    (c-offsets-alist
     (knr-argdecl-intro		. 5)
     (statement-block-intro	. +)
     (substatement-open		. 0)
     (label			. 0)
     (statement-cont		. +)
     (inline-open		. 0))
    
    (c-cleanup-list . '(brace-else-brace)))
  "My own CC Mode source code formatting style.")

;; Not much difference really... but anyway here is the 'official'
;; coding style settings for Emacs at cisco.
(defvar cisco-c-style
  '((c-auto-newline                 . nil)
    (c-basic-offset                 . 4)        
    (c-block-comments-indent-p      . nil)
    (c-comment-only-line-offset     . 0)
    (c-echo-syntactic-information-p . nil)
    (c-hanging-comment-ender-p      . t)
    (c-recognize-knr-p              . t) ; use nil if only have ANSI prototype
    (c-tab-always-indent            . nil)
    (comment-column                 . 40)
    (comment-end                    . " */")
    (comment-multi-line             . t)
    (comment-start                  . "/* ")
    (c-hanging-comment-ender-p      . nil)
    (c-offsets-alist                . ((knr-argdecl-intro   . +)
                                       (case-label          . 0)
                                       (knr-argdecl         . 0)
                                       (label               . 0)
                                       (statement-case-open . +)
                                       (statement-cont      . +)
                                       (substatement-open   . 0))))
  "cisco c-style for cc-mode")

(require 'cc-mode)
; causes an error - as this is not allowed in non-CC mode files
;(c-add-style "Personal" my-c-style t)
; (setq c-default-style
;	'((other . "personal")))

;; some general stuff like turning on hungry delete and such
(defun c-and-c++-mode-stuff ()
  "Custom setup meant for all CC Modes."
  (setq c-cleanup-list '(brace-else-brace
			 brace-elseif-brace
			 empty-defun-braces
			 defun-close-semi))
  (c-toggle-hungry-state 1)
  (setq  c-toggle-auto-hungry-state t
	 compilation-scroll-output t
	 indent-tabs-mode nil))

;; The functions in this hook variable are run for all c-like modes;
;; i.e. for C, C++, Java etc.  More or less what we do for a living :)
(add-hook 'c-mode-common-hook (function c-and-c++-mode-stuff))

(defun text-mode-hook-func ()
  (when (fboundp 'filladapt-mode)
    (filladapt-mode t))
  (turn-on-auto-fill)
  (setq fill-column 78))

;; Text-based modes (including mail, TeX, and LaTeX modes) are auto-filled.
(add-hook 'text-mode-hook 'text-mode-hook-func)

;; asm mode hook changes the comment character from the defaul ';' to #
;; -- The syntax applies to both MIPS and X86 assembly...
(add-hook 'asm-mode-hook
 	  (lambda ()
 	    (setq asm-comment-char ?#)
	    (setq comment-start "# ")
	    (setq block-comment-start "/*")
	    (setq block-comment-end "*/")))

;; This gives the form of the default compilation command for C++, C, and
;; Fortran programs.  Specifying the "-lm" option for C and C++  eliminates a
;; lot of potential confusion.

(defvar compile-guess-command-table
  '((c-mode       . "gcc -g %s -o %s -lm") ; Doesn't work for ".h" files.
    (c++-mode     . "g++ -g %s -o %s -lm") ; Doesn't work for ".h" files.
    (fortran-mode . "f77 -C %s -o %s")
    )
  "*Association list of major modes to compilation command descriptions.
Used by the function `compile-guess-command'.  For each major mode, the
compilation command may be described by either:

  + A string, which is used as a format string.  The format string must
    accept two arguments: the simple (non-directory) name of the file to be
    compiled, and the name of the program to be produced.

  + A function.  In this case, the function is called with the two
    arguments described above and must return the compilation command.")


;; This code guesses the right compilation command when Emacs is asked
;; to compile the contents of a buffer.  It bases this guess upon the
;; filename extension of the file in the buffer.

(defun compile-guess-command ()

  (let ((command-for-mode (cdr (assq major-mode
                                     compile-guess-command-table))))
    (if (and command-for-mode
             (stringp buffer-file-name))
        (let* ((file-name (file-name-nondirectory buffer-file-name))
               (file-name-sans-suffix (if (and (string-match "\\.[^.]*\\'"
                                                             file-name)
                                               (> (match-beginning 0) 0))
                                          (substring file-name
                                                     0 (match-beginning 0))
                                        nil)))
          (if file-name-sans-suffix
              (progn
                (make-local-variable 'compile-command)
                (setq compile-command
                      (if (stringp command-for-mode)
                          ;; Optimize the common case.
                          (format command-for-mode
                                  file-name file-name-sans-suffix)
                        (funcall command-for-mode
                                 file-name file-name-sans-suffix)))
                compile-command)
            nil))
      nil)))


;; Add the appropriate mode hooks.
(add-hook 'c-mode-hook       (function compile-guess-command))
(add-hook 'c++-mode-hook     (function compile-guess-command))
(add-hook 'fortran-mode-hook (function compile-guess-command))

;; This creates and adds a "Compile" menu to the compiled language modes.
(defvar compile-menu nil
  "The \"Compile\" menu keymap.")

(defvar check-option-modes nil
  "The list of major modes in which the \"Check\" option in the \"Compile\"
menu should be used.")

(defvar compile-menu-modes nil
  "The list of major modes in which the \"Compile\" menu has been installed.
This list used by the function `add-compile-menu-to-mode', which is called
by various major mode hooks.")


;; Create the "Compile" menu.
(if compile-menu
    nil
  (setq compile-menu (make-sparse-keymap "Compile"))
  ;; Define the menu from the bottom up.
  (define-key compile-menu [first-error] '("    First Compilation Error" .
                                           first-compilation-error))
  (define-key compile-menu [prev-error]  '("    Previous Compilation Error" .
                                           previous-compilation-error))
  (define-key compile-menu [next-error]  '("    Next Compilation Error" .
                                           next-error))
  (define-key compile-menu [goto-line]   '("    Line Number..." .
                                           goto-line))

  (define-key compile-menu [goto]        '("Goto:" . nil))
  ;;
  (define-key compile-menu [indent-region] '("Indent Selection" .
                                             indent-region))

  (define-key compile-menu [make]         '("Make..." . make))

  (define-key compile-menu [check-file]   '("Check This File..." . 
                                            check-file))

  (define-key compile-menu [compile]     '("Compile This File..." . compile))
  )

;; Enable check-file only in Fortran mode buffers
(put 'check-file 'menu-enable '(eq major-mode 'fortran-mode))

;; Here are the new commands that are invoked by the "Compile" menu.
(defun previous-compilation-error ()
  "Visit previous compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
  (interactive)
  (next-error -1))

(defun first-compilation-error ()
  "Visit the first compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
  (interactive)
  (next-error '(4)))

(defvar check-history nil)

(defun check-file ()
  "Run ftnchek on the file contained in the current buffer"
  (interactive)
  (let* ((file-name (file-name-nondirectory buffer-file-name))
         (check-command (read-from-minibuffer
                         "Check command: "
                         (format "ftnchek %s" file-name) nil nil
                         '(check-history . 1))))
    (save-some-buffers nil nil)
    (compile-internal check-command "Can't find next/previous error"
                      "Checking" nil nil nil)))

(defun make ()
  "Run make in the directory of the file contained in the current buffer"
  (interactive)
  (save-some-buffers nil nil)
  (compile-internal (read-from-minibuffer "Make command: " "make ")
                    "Can't find next/previous error" "Make"
                    nil nil nil))


;; Define a function to be called by the compiled language mode hooks.
(defun add-compile-menu-to-mode ()
  "If the current major mode doesn't already have access to the \"Compile\"
menu, add it to the menu bar."
  (if (memq major-mode compile-menu-modes)
      nil
    (local-set-key [menu-bar compile] (cons "Compile" compile-menu))
    (setq compile-menu-modes (cons major-mode compile-menu-modes))
    ))

;; And finally, make sure that the "Compile" menu is available in C, C++, and
;; Fortran modes.
(add-hook 'c-mode-hook       (function add-compile-menu-to-mode))
(add-hook 'c++-c-mode-hook   (function add-compile-menu-to-mode))
(add-hook 'c++-mode-hook     (function add-compile-menu-to-mode))
(add-hook 'fortran-mode-hook (function add-compile-menu-to-mode))

;; some gambit scheme related stuff. -- I was using Gambit for a while.
;; Now started using Guile.
;; (autoload 'gambit-inferior-mode "gambit" "Hook Gambit mode into cmuscheme.")
;; (autoload 'gambit-mode "gambit" "Hook Gambit mode into scheme.")
;; (add-hook 'inferior-scheme-mode-hook (function gambit-inferior-mode))
;; (add-hook 'scheme-mode-hook (function gambit-mode))
;; (setq scheme-program-name "gsi -:t")

;; add the OpenGL mode - Commented out 14-10-2001.  Hardly use OpenGL
;; nowadays -- what a waste
;; (add-hook 'c-mode-hook
;; 	  (lambda ()	    
;; 	    ;; this is stuff for the OpenGL minor mode which I was
;; 	    ;; using for cg II.  could not think of something more
;; 	    ;; generic.
;; 	    (when
;; 		(and (buffer-file-name)
;; 		     (string-match "cs6610/"
;; 				   (buffer-file-name))
;; 		     (load-library-carefully
;; 		      'OpenGL
;; 		      nil
;; 		      (lambda ()
;; 			(OpenGL-minor-mode 1)
;; 			(OpenGL-setup-keys))
;; 		      (lambda ()
;; 			(message "OpenGL.elc? not found.  We installed it")))))
;; 	    (c-and-c++-mode-stuff)))



;; Printing related stuff.
(defun set-up-printing-stuff()
  "Customize the variables in nifty printing.el packge."
  (setq pr-txt-name      (make-symbol my-printer-name))
  (setq pr-txt-printer-alist
	(list (list my-printer-symbol my-lpr-command nil my-printer-name)))
  (setq pr-ps-name       (make-symbol my-printer-name))
  (setq pr-ps-printer-alist
	(list (list my-printer-symbol my-lpr-command nil "-P "
		    my-printer-name)))
  (setq pr-temp-dir      "/tmp/")
  (setq pr-gv-command    "gv")
  (setq pr-gs-command    "gs")
  (setq pr-gs-resolution 300)
  (setq pr-ps-utility    'mpage)
  (setq pr-file-duplex t)
  (setq pr-ps-utility-alist
	'((mpage "mpage"    "-b%s" "-%d" "-l" "-t" "-T" ">" nil)
	  (psnup "psnup -q" "-P%s" "-%d" "-l" nil  nil  " " nil
		 (:inherits-from . duplex))))
  (pr-update-menus t))

(defun set-up-ps-print-stuff ()
  "Customize variables that come in the ps-print package."
  (setq ps-lpr-command   my-lpr-command
	lpr-command	 my-lpr-command
	ps-lpr-switches  my-lpr-switches
	lpr-switches     my-lpr-switches
	ps-printer-name  my-printer-name
	pr-file-duplex   t
	ps-spool-duplex  t
	ps-paper-type    (if (or (eq whereami 'hcl-nt)
				 (eq whereami 'hcl-linux)
				 (eq whereami 'techm-blr))
			     'a4
			   'letter)
  	ps-printer-name-option my-printer-name-option)

  (defmacro pspn (n)
    "Print the buffer with 'n' pages per sheet"
    `(let ((ps-n-up-printing ,n))
       (ps-print-buffer nil)))

  (defmacro pspnr (n)
    "Print the region with 'n' pages per sheet"
    `(let ((ps-n-up-printing ,n))
       (ps-print-region (point) (mark))))

  (defun psp1 ()
    "Print current buffer one page per sheet"
    (interactive)
    (pspn 1))

  (defun psp1r ()
    "Print current region one page per sheet"
    (interactive)
    (pspnr 1))

  (defun  psp2 ()
    "Print current buffer two pages per sheet"
    (interactive)
    (pspn 2))

  (defun psp2r ()
    "Print current region two pages per sheet"
    (interactive)
    (pspnr 2)))

(load-library-carefully 'ps-print
			nil
			'set-up-ps-print-stuff)

(condition-case err
    (load-library-carefully 'printing
			    nil
			    'set-up-printing-stuff)
  (error nil))


;;; Misc. stuff

;; This stuff is a patched version of the routine from outline.el.  The
;; patch comes from Peter Heslin  <pj@heslin.eclipse.co.uk> and fixes a
;; long time beef I have had with Outline.  Basically, when you 'hide'
;; using C-c C-q in outline, even the initial text before the first
;; heading also gets hidden.  This is frigging outrageous...  This
;; patched version solves the issue by ensuring the stuff before the
;; first heading cannot be hidden by any of the hide commands.
;; Absolutely wonderful, if you ask me.  NOTE: This stuff is already in
;; Emacs CVS.
(defun hide-region-body (start end)
  "Hide all body lines in the region, but not headings."
  ;; Nullify the hook to avoid repeated calls to `outline-flag-region'
  ;; wasting lots of time running `lazy-lock-fontify-after-outline'
  ;; and run the hook finally.
  (let (outline-view-change-hook)
    (save-excursion
      (save-restriction
	(narrow-to-region start end)
	(goto-char (point-min))
	(if (outline-on-heading-p)
	    (outline-end-of-heading)
	  (outline-next-preface))
	(while (not (eobp))
	  (outline-flag-region (point)
			       (progn (outline-next-preface) (point)) t)
	  (unless (eobp)
	    (forward-char (if (looking-at "\n\n") 2 1))
	    (outline-end-of-heading))))))
  (run-hooks 'outline-view-change-hook))

;; This routine is useful in the specific clearcase setup at cisco.
(defun find-all-cos (view)
  "Open all checked out files in given view on the current server.
This is particularly useful when there has been a server
shutdown or some such and we need to quickly get back to our editing
state and we did not save the desktop state..."
  (interactive)
  (let ((f-list)
	(sys (concat "/view/" view "/vob/ios/")))
    (if (file-directory-p sys)
	(mapcar (lambda (fi)
		  (find-file fi))
		(split-string (shell-command-to-string
		      (concat "cd " sys " && cc_cset -s"))))
      (message "No such view %s" view))))

;; It is a bloody pita to have a non-duplex printer...  Here are some
;; wrappers to make our life a little less miserable.

(defun k-pr ()
  "Intelligently print the buffer using `ps-print-buffer'.
This will enable 2-column landscape mode only if there is more than one
page to print.  It is kinda dumb to have a single page of output crammed
into one half of an otherwise empty page of white paper..."
  (interactive)

  (ps-print-buffer))

(defun k-pr-odd ()
  "Print all the odd pages of the buffer using `ps-print-buffer'."
  (interactive)

  (odd)
  (let ((ps-even-or-odd-pages 'odd-page))
    (k-pr)))

(defun k-pr-even ()
  "Print all the even pages in the bugger using `ps-print-buffer'."
  (interactive)

  (let ((ps-even-or-odd-pages 'even-page))
    (ps-print-buffer)))

;; Many times I edit files with a "Last Modified" entry at the top of
;; the file.  It would be great if we can modify the time stamp in that
;; line automatically whenever a buffer is saved.

;; ;; Look into "time-stamp.el" which provides a similar functionality.
;; ;; Perhaps there is something we can pick up from there.

(defvar k-lmod-regex "last modified\\S+:\\S+\\(.*?[0-9][0-9][0-9][0-9]\\)"
  "The string to match the last modified field.")

(defvar k-lmod-limit 2000
  "The limit for searching for the occurence of `k-update-lmod-regex'.
This is a buffer position.")

(defun k-lmod-update ()
  "Search the buffer from the beginning and update any \"last modified\"
timestamp."
  (interactive)

  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward k-lmod-regex k-lmod-limit t)
	(replace-match (format-time-string my-time-format-string)
		       nil nil nil 1))))

(add-hook 'write-file-hooks 'k-lmod-update)

(defmacro find-library (lib)
  "Locate and display the given library name if available."

  (interactive "s")
  (let ((path (locate-library lib)))
    (if path
	`(find-file ,path)
      nil)))

(GNUEmacs21
 (require 'woman)
 (setq woman-cache-filename (expand-file-name "~/.wmncach.el")))

(setq next-line-add-newlines		nil
      line-number-mode                  t
      default-major-mode                'text-mode
      require-final-newline             t
      set-comment-column                26)

;; make CVS the default version control program in VC mode
(setq vc-default-back-end 'CVS)

;; But we somtimes need RCS as well...  CVS and Emacs VC are not really
;; meant for each other.
;; (setq vc-default-back-end 'RCS)

;; Cause the region to be highlighted and prevent region-based commands
;; from running when the mark isn't active.
(pending-delete-mode t)
(setq transient-mark-mode t)

;; force emacs to confirm before you quit
(setq kill-emacs-query-functions
  (list (lambda ()
	  (ding)
	  (y-or-n-p "Really quit? "))))

;; turn on the goddamn upcase and down case stuff
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; enable dynamic sizing of the minibuffer when the input is bigger
;; than one line. This is no longer requried for Emacs 22+)
(when (fboundp 'resize-minibuffer-mode)
  (resize-minibuffer-mode 1)
  (setq resize-minibuffer-window-exactly nil))

;; enable column number mode.  now, we have the coloumn number displayed
;; in the mode line.  I can't believe it that this is not the default
(column-number-mode t)

;; display the  time and  mail flag  in the mode  line.  All  this stuff
;; takes up  a lot of space  in the mode line.   So much so  that in the
;; default setup of  the modeline format, the line  numbers are not even
;; visible!  Ofcourse most of the blame for this nonsense should fall on
;; the display of the mode names.
(add-hook 'display-time-hook
	  (lambda ()
	    (setq display-time-24hr-format t)
	    (setq display-time-day-and-date t)))
(display-time)

;; loading the abbreviation file
(GNUEmacs
 (setq-default abbrev-mode t)
 (setq save-abbrevs t)
 (if (file-exists-p "~/.abbrev_defs")
     (read-abbrev-file "~/.abbrev_defs")
   (message "abbreve file ~/.abbrev_defs could not be located.")))

;; the grade file for cs2020 is getting a little too big.  turn off
;; auto-fill-mode if we are loading this file - NOT used this shit in a
;; long while.
;; (add-hook 'find-file-hooks
;; 	  (lambda ()
;; 	    (if (string= (file-name-nondirectory
;; 			  (buffer-file-name))
;; 			 "grades.txt")
;; 		(auto-fill-mode -1))))

;; put all the results of customisations from inside emacs at the end of
;; .customs.emacs and not .emacs which is the default
(setq custom-file "~/.customs.emacs")

;; set the name of my diary.  By  default it is ~/diary.  we will set it
;; to to .diary, and  start the diary - so we can  now keep track of the
;; latest events.
(if (file-exists-p "~/.diary")
    (progn
	(setq diary-file "~/.diary")
	;; Sometimes diary entries will have time based entries (like
	;; appointment at 10am etc.), the following will make reminders
	;; pop up, at a convenient time. -- Important thing is,
	;; (display-time) must have been evaled for this to work.
	(add-hook 'diary-hook 'appt-make-list)
	(diary 0))
  (message "diary file not found in ~/.  look into it."))

;; enable copy/cut/paste through the windows clipboard also.
;; Otherwise its a pain in the ass when running with exceed.
;; (setq x-select-enable-clipboard t)

;; When there are a number of  Emacs sessions open, and are fighting for
;; place  on  a  windows toolbar,  it  is  more  important to  have  the
;; system-name than the invocation name  on the title (the default) of a
;; frame.  Let us "Make it so"
(setq frame-title-format '(multiple-frames "%b"
					   ("" system-name)))

;; Our mode-line is in a really  awful state... So much stuff there that
;; it is ridiculous.  On April 5th, 2001 I decided to do something about
;; this crap...  So,  I decided to have 3  mode-line formats and arrange
;; to switch between them by pressing the magic C-= key
;; NOTE: This choice of key binding was not particularly, er., good.
;; My linux console does not generate any keysym for that combo...  I
;; have been unable to change the keymaps.gz file...  It was a total,
;; er. waste.  Anyways, this works under X.

;; This is an edited version of Emacs' default minor-mode-alist
(setq my-minor-mode-alist
      '((cvs-minor-mode " CVS")
	(vc-mode vc-mode)
	(overwrite-mode overwrite-mode)
	(auto-fill-function " Fill")
	(defining-kbd-macro " Def")
	(isearch-mode isearch-mode)))

(defvar my-mode-line-formats

  ;; Display 
  '(("-" mode-line-mule-info mode-line-modified
	 mode-line-frame-identification mode-line-buffer-identification
	 " " global-mode-string
	     "  %[(" mode-name mode-line-process
			       my-minor-mode-alist "%n" ")%]--"
			       (line-number-mode "L%l--")
			       (column-number-mode "C%c--")
			       (-3 . "%p")
			       "-%-")
    ("-" mode-line-mule-info mode-line-modified
	 mode-line-frame-identification mode-line-buffer-identification
	 "    %[(" mode-name mode-line-process
			     my-minor-mode-alist "%n" ")%]--"
			     (line-number-mode "L%l--")
			     (column-number-mode "C%c--")
			     (-3 . "%p")
			     "-%-")
    ("-" mode-line-mule-info mode-line-modified
	 mode-line-frame-identification mode-line-buffer-identification
	 "   " global-mode-string
	       "   %[(" mode-name mode-line-process
				  minor-mode-alist "%n" ")%]--"
				  (which-func-mode ("" which-func-format "--"))
				  (line-number-mode "L%l--")
				  (column-number-mode "C%c--")
				  (-3 . "%p")
				  "-%-"))
  "List of mode-line-formats.
This is just a list of objects each of which can be used as the value for
`mode-line-format'.  You should use the function
`my-mode-line-switch-formats' to rotate between the formats in this list.")

;; The idea for the switching code has been lifted, with thanks, from Colin
;; Walters' ibuffer.el
(defun switch-mode-line-formats ()
  "Switch the format of current mode-line.
Everytime this function is called, the formats available in
`my-mode-line-formats' are cycled through.  Note that calling this function
changes the modeline for the current buffer.  That is because
`mode-line-format' is a buffer-local variable."
   (interactive)
   (unless (consp my-mode-line-formats)
     (error "Dude! Stop screwing with my-mode-line-formats. It is empty"))
   (setq mode-line-format
	 (or (cadr (member mode-line-format my-mode-line-formats))
	     (car my-mode-line-formats)))
   (force-mode-line-update))

(global-set-key [?\C-=] 'switch-mode-line-formats)
(setq-default mode-line-format (car my-mode-line-formats))

;; Some Tex-mode related stuff
(setq tex-dvi-print-command
      '(concat
	"dvips -f * > "
	(file-name-sans-extension (file-name-nondirectory (buffer-file-name)))
	".ps"))
(setq tex-dvi-view-command
      '(concat
	"dvips -f * > /tmp/karras.ps; gv /tmp/karras.ps"))

;; An intersting post to g.e.{s,g}
;; From: davep.news@davep.org (Dave Pearson)
;; Subject: Re: Tip of the Day
(defun totd ()
  (interactive)
  (with-output-to-temp-buffer "*Tip of the day*"
    (let* ((commands (loop for s across obarray
                           when (commandp s) collect s))
           (command (nth (random (length commands)) commands)))
      (princ
       (concat "Your tip for the day is:\n========================\n\n"
               (describe-function command)
               "\n\nInvoke with:\n\n"
               (with-temp-buffer
                 (where-is command t)
                 (buffer-string)))))))

;; The bizzare two-letter funtions that follow were written in the heat
;; of an unknown moment, and found their way into the maze of this file
;; at a later, but equally unknown, moment.  Live and let live...
(defun ma ()
  (interactive)

  (insert (concat (current-time-string) "; " user-full-name " <"
		  user-mail-address ">: "))
  (newline-and-indent) (insert "// ")
  (newline-and-indent) (insert "// "))

(defvar comment-banner
  (concat "// =================================="
	  "==================================="))

(defun me ()
  (interactive)
  (insert (concat comment-banner "\n" "// \n" "// "))
  (save-excursion
    (insert (concat "\n" "// \n" comment-banner "\n\n"))))

(defun mi ()
  (interactive)
  (indent-according-to-mode) (insert comment-banner)
  (newline-and-indent) (insert "// ")
  (newline-and-indent) (insert "// ")
  (ma)

  (save-excursion
    (newline-and-indent) (insert "// ")
    (newline-and-indent) (insert comment-banner "\n\n")))

;; Some LIH related stuff:
;; I have expanded this stuff into something more complex... It's in a
;; file somewhere in ~/elisp...
(defvar lost-dir (expand-file-name "~/etc/signature/LOST"))
(defun select-lost ()
  "Inserts a random LOST file from `lost-dir' at point (i.e. cursor)."
  (interactive)
  (let* ((files (vconcat (directory-files lost-dir t "[0-9]*.lost")))
	 (len (length files))
	 (ran-index (% (abs (random t)) len))
	 (random-lost-fname (aref files ran-index)))
    (insert-file random-lost-fname)))

;;;; No customisations beyond this point.

;;
;; finally, lets wrap up by doing the machine dependent final stuff.
;; Commented out because we have moved away from this style of doing
;; things.
;; (when machine-dep-customs-exists
;;   (do-final-machine-dependent-stuff))


;;; Misc. stuff.  Generally unused.  But might come in useful some day.

(when nil

  ;; Suggestion made to Frank Klotz on Fri Oct 8 11:50:04 2004 to rename
  ;; the buffer name for M-x compile
  (setq compilation-buffer-name-function
	(lambda (major)
	(concat "*Compiling in " default-directory " *")))
  )

;;; Stuff from M-x customize thingy. Mess with caution.

(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(bbdb-gui t)
 '(c-electric-pound-behavior (quote (alignleft)))
 '(c-progress-interval 1)
 '(canlock-password "5148c33e6e24075d9474f6c88f32dad97b131909")
 '(mail-yank-ignored-headers (concat "^via:\\|^mail-from:\\|^origin:\\|^status:\\|^remailed\\|" "^received:\\|^message-id:\\|^summary-line:\\|^to:\\|" "^in-reply-to:\\|^return-path:\\|^content.*:\\|^x-.*:\\|" "^organization:\\|^mailing-list:\\|^precedence:\\|" "^list-unsubscribe:\\|^reply-to:\\|^importance:\\|^cc:"))
 '(ps-n-up-border-p nil)
 '(ps-n-up-margin 0)
 '(ps-n-up-printing 2)
 '(recentf-max-menu-items 30)
 '(recentf-max-saved-items 30))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 )
