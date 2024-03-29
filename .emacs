;;--------------------------------------------
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ispell-program-name "aspell")
 '(package-selected-packages
   (quote
    (dockerfile-mode syslog-mode js2-mode ess json-mode pylint writeroom-mode zenburn-theme flyspell-correct php-mode markdown-mode+ markdown-mode goto-last-change yaml-mode magit elpy))))

;;--------------------------------------------
;; ADAPTED FROM WILL'S STANDARD EMACS FILE:
(global-set-key "\C-xr" 'replace-string)
(global-set-key "\C-xc" 'compile)
(setq make-backup-files 'nil)

;;--------------------------------------------
;; FONT SIZE for 4k monitor
(set-face-attribute 'default nil :height 150)

;;----------------------------------------------------------------------------
;; ELPY
(use-package elpy
	     :ensure t
	     :init
	     (elpy-enable)
	     :config
	     (setq python-shell-interpreter "ipython"
		   python-shell-interpreter-args "--simple-prompt -i"
		   elpy-rpc-virtualenv-path 'current))

;;----------------------------------------------------------------------------
;; WHITESPACE - commenting out for now as it overrides flake8's line-length
;; detection (and, under the hood, elpy uses flake8)
;(require 'whitespace)
;(setq whitespace-style '(face tabs lines-tail))
;(setq whitespace-line-column 80)
;(global-whitespace-mode t)
;(setq whitespace-global-modes '(c-mode c++-mode python-mode))

;;---------------------------------------------------------------------------
;; COLOUR THEME
(use-package zenburn-theme
	     :ensure t
	     :config
	     (load-theme 'zenburn t))


;;----------------------------------------------
;; RECENTLY USED FILES
;; http://www.emacswiki.org/RecentFiles
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)


;;----------------------------------------------
;; TWEAKS FROM http://www-cdf.fnal.gov/~sthrlnd/emacs_help.html

;; get rid of the toolbar on top of the window
(tool-bar-mode 0)

;; Show column number at bottom of screen
(column-number-mode 1)

;; turn on paren matching
(show-paren-mode t)
(setq show-paren-style 'mixed)

;; Use "y or n" answers instead of full words "yes or no"
(fset 'yes-or-no-p 'y-or-n-p)

;; Tell markdown-live-preview-mode to use pandoc
(setq markdown-command "/usr/bin/pandoc")


;;----------------------------------------------
;; MAGIT
;; https://github.com/magit/magit
(use-package magit
  :ensure t
  :bind ("C-x C-g" . magit-status))
(require 'magit)


;;----------------------------------------------------------------------------
;; SPELLING
(defun turn-on-flyspell () (flyspell-mode 1))
(setq ispell-check-comments t)
(setq ispell-dictionary "en_GB")
(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(c++-mode-hook python-mode-hook))
  (add-hook hook (lambda () (flyspell-prog-mode))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))


;;------------------------------------------------
;; IDO mode
;; http://emacswiki.org/emacs/InteractivelyDoThings
(require 'ido)
(ido-mode t)


;;----------------------------------------------------------------------------
;; goto-last-change
;; from http://www.emacswiki.org/emacs/goto-last-change.el
(global-set-key "\C-x\C-\\" 'goto-last-change)


;;----------------------------------------------------------------------------
;; disable startup screen
(setq inhibit-startup-screen t)


;;----------------------------------------------------------------
;; never use tabs!
;; from: http://www.pement.org/emacs_tabs.htm
(setq-default indent-tabs-mode nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
