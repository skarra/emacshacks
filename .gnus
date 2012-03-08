;;; -*-emacs-lisp-*- Gnus startup file.

;; Created       : Febraury 2, 2001
;; Last Modified : Thu Mar 08 13:15:26 IST 2012
;;
;; Copyright (C) 2001 - 2012, Sriram Karra <karra.etc@gmail.com>
;; Feel free to do as you please with this code
;;
;; This is the customisation file for the gnus mail/news reader for
;; emacs.  This is my first full blown attempt to use gnus...  had to
;; happen sometime...

;;; Some Basic Stuff

;; Objective is to regain expert status some day.
;; (setq gnus-expert t)

;;; Groups split rules and posting style specification.

;; setup the different posting styles.  I think it suffices for now just to
;; set the From: header
(setq gnus-posting-styles
      '((".*"
	 (signature-file "~/.signature")
	 (name mail-user-name)	       ; set somewhere in .customs.emacs
	 (address "sriram.karra@cleartrip.com"))
	))

;;; Mail source specifications

;; for security reasons, we have moved the pop sources (and their
;; passwords) to another file that is only readable by us.

(condition-case err
    (load-file (expand-file-name "~/.gnus.private"))
  (error
   (defvar my-all-mail-sources '((file))
     "Value used to initialise the gnus variable `mail-sources'.
A value of (file) only means that mail will be fetched only from
the local mail spool.  ")))

(unless (boundp 'whereami)
  (defvar whereami nil))

;;; Location specific customizations

(cond
 ;; In Cleartrip we are moslty interested in a mail solution - depending on
 ;; offlineimap and dovecot to provide an imap interface on local machine
 ((eq whereami 'cleartrip)
  (setq gnus-secondary-select-methods
	'((nnimap "Cleartrip"
		  (nnimap-address "localhost")
		  (nnimap-stream network)
		  (nnimap-authenticator login))))
  (setq gnus-select-method '(nntp "news"))
  (setq mail-sources my-all-mail-sources)
  (setq message-send-mail-function 'message-send-mail-with-sendmail)

  (setq gnus-message-archive-method '(nnimap "Cleartrip"))
  (setq gnus-update-message-archive-method t)
  (setq gnus-message-archive-group "Cleartrip.Sent Messages")
  )
 )

;;
;; swish-e and nnir.el -- What follows is from an earlier implementation; need
;; to customize shortly (Wed Feb 29 15:18:21 IST 2012)
;;
;; (setq nnir-mail-backend (nth 0 gnus-secondary-select-methods)
;;       nnir-search-engine 'swish-e
;;       nnir-swish-e-index-file (expand-file-name "~/Mail/swish-e.index"))

(setq gnus-show-mime t)
;; When we forward mails, we would like to maintain the integrity of the
;; MIME attachments/parts/whatever...  Setting the following variable
;; accomplishes that.
(setq message-forward-as-mime t)

;; There are many ways to deal with html mails.  Most half-decent mail
;; programs these days send multi-part mails.  i.e. the same stuff is
;; formatted as text as well as html and sent as attachments of
;; different mime types - text/plain and text/html.  The following
;; setting makes sure that if we get a multipart/alternate mail, we
;; would not like to look at the following mime types.
(setq mm-discouraged-alternatives '("text/html" "text/richtext"))

(setq gnus-article-wash-function 'w3m)
(setq mm-text-html-renderer 'w3m)

;; This will force Emacs to display the image attachments inline...
(add-to-list 'mm-attachment-override-types "image/.*")

(add-hook 'gnus-summary-mode-hook 'turn-on-gnus-mailing-list-mode)

;; Prompt for fetching more than 100 messages from a group.
(setq gnus-large-newsgroup 100)

;; The number of groups I am subscribed to is growing fast and furious...
;; gnus-topicc-mode is great to organise them in some logical way.  It is a
;; actually a big pain that the information about `topics', that I have
;; customised is all stored away in the .newsrc.eld file.  So, it is going
;; to be one painful problem moving all this customization to another
;; machine.
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

;; Some gunks have a habit of sending mails with a thousand addresses in
;; the To: field...  gnus has a way to fight these retards...
(setq gnus-treat-hide-boring-headers 'head)
(setq gnus-boring-article-headers (list 'long-to))

;; A list of the headers we are interested in.  You are right, most of
;; the things listed here are Gnus defaults.  Only the user-agent and
;; x-mailer headers are our own additions... However based on past
;; experience, customizing such variables by (concat) ing to the already
;; initialized variable is frought with perils because we potentially
;; eval our .gnus file multiple times...  Maye the world needs a new
;; macro that acts like concat but only after checking for the presence
;; of the candidate string first ... Or maybe there already is something
;; along these lines...  
(setq gnus-visible-headers
      (concat "^From:\\|^Newsgroups:\\|^Subject:\\|^Date:\\|"
	      "^Followup-To:\\|^Reply-To:\\|^Organization:\\|"
	      "^Summary:\\|^Keywords:\\|^To:\\|^[BGF]?Cc:\\|"
	      "^Posted-To:\\|^Mail-Copies-To:\\|^Mail-Followup-To:\\|"
	      "^Apparently-To:\\|^Gnus-Warning:\\|^Resent-From:\\|"
	      "^X-Sent:\\|^X-Mailer\\|^User-Agent\\|^X-Interest-Karra"))

;; When replying to messages we would like certain headers to be
;; included in the quoted text.  for.e.g the date of the original
;; message and stuff.  As of this writing, there is no direct way in
;; which we can specify just these headers.  Instead we need to set the
;; following variable to a list headers that we want to be _removed_.
;; *sigh*.
(setq message-ignored-cited-headers
      (concat 
       "^X\\|^R\\|^O\\|^L\\|^I\\|^M\\|^U\\|^Content"))

;; In many cases, it is not fun to look at our name in the summary buffer -
;; For e.g. in the archive groups, all articles are written by us - the
;; following might help
(setq gnus-extra-headers '(To Newsgroups)
      nnmail-extra-headers '(To Newsgroups)
      gnus-summary-line-format "%U%R%z%I%(%[%4L: %-20,20f%]%) %s\n")

;; The default *Group* buffer mode line contains the name of the news
;; server.  This can get a little big, messy and obscure some important
;; info to the right end of the modeline.  The default is:
;; "Gnus: %%b {%M%:%S}"
(setq gnus-group-mode-line-format "Gnus: %%b {%M}")

;; In many cases, it is not fun to look at our name in the summary buffer -
;; For e.g. in the archive groups, all articles are written by us - the
;; following might help
(setq gnus-extra-headers '(To Newsgroups)
      nnmail-extra-headers '(To Newsgroups)
      gnus-summary-line-format "%U%R%z%I%(%[%4L: %-20,20f%]%) %s\n")

;; If the From header has any of these values, the "To" address is
;; displayed in the Summary buffer.  This is useful when we are looking
;; at mails _we_ have sent out, like in archive groups and stuff.
(setq gnus-ignored-from-addresses 
      (concat "\\(\\(sriram\\)?karra@\\("
	      "\\(\\([^\\.]+\\.\\)?\\(cs\\|eng\\)\\.utah\\.edu\\)"
	      "\\|cleartrip.com"
	      "\\|intel\\.com"
	      "\\|yahoo\\.com"
	      "\\|hotmail\\.com"
	      "\\)\\|ksriram@prodapt\\.com\\)"))
(setq gnus-ignored-from-addresses
      (concat "\\(" gnus-ignored-from-addresses
	      "\\)\\|\\(karra@shakti\\.homelinux\\.net\\)"
	      "\\|\\(skarra@cisco\\.com\\)"))

;; Disable CC: to self in wide replies and stuff
(setq message-dont-reply-to-names gnus-ignored-from-addresses)

(setq gnus-parameters
      '(("^nnimap\\+Cleartrip:Cleartrip\\.Jira"
	 (sieve header :contains "subject" "[Jira].*"))))

;; Set up Gnus Sieve Support
(setq gnus-sieve-file "~/.gnus.siv")
(autoload 'sieve-mode "sieve-mode")
(setq auto-mode-alist (cons '("\\.siv\\'" . sieve-mode) auto-mode-alist))
(require 'gnus-sieve)

;; Mark all the sent messages as read
(setq gnus-gcc-mark-as-read t)

;; Refer to ~/.customs.emacs for doc about switch-mode-line-formats
(setq gnus-started-hook
      (lambda ()
	(when (fboundp 'switch-mode-line-formats)
	  (switch-mode-line-formats)
	  (switch-mode-line-formats))))

(if (fboundp 'customize-gnus-colors)
    (customize-gnus-colors))

;;; No customizations beyond this point

;; This will make Gnus an offline reader.  (We can "send" mail and news
;; articles and they will be put in a special "queue" group.  We can send
;; them all at once when we connect to the net once again.
;;(setq gnus-agent-send-mail-function message-send-mail-function)
(gnus-agentize)
