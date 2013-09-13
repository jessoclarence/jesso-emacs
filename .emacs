;;; package --- Jesso's init file

;;; Commentary:
; My experiments Sept 11, 2013

;;; Code:

; Show line numbers
(global-linum-mode 1)

; Remove icon-bar
(tool-bar-mode -1)

; Delete trailing whitespace on file save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

; Highlight chars after 80 col limit
(require 'whitespace)
 (setq whitespace-style '(face empty tabs lines-tail trailing))
 (global-whitespace-mode t)

; load theme
(load-theme 'tango-dark t)

; Save buffer list on exit
(require 'desktop)
  (desktop-save-mode 1)
  (defun my-desktop-save ()
    (interactive)
    ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
    (if (eq (desktop-owner) (emacs-pid))
        (desktop-save desktop-dirname)))
  (add-hook 'auto-save-hook 'my-desktop-save)

; Full screen open
(defun toggle-fullscreen ()
  (interactive)
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
)
(toggle-fullscreen)

; Enable IDO mode
(require 'ido)
(ido-mode t)

; Enable jedi for python
(add-hook 'python-mode-hook 'auto-complete-mode)
(add-hook 'python-mode-hook 'jedi:ac-setup)
(setq jedi:complete-on-dot t)

; Enable flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

; Colored terminal in emacs "M-x term" to open
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

; el-get - package manager
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (let (el-get-master-branch)
      (goto-char (point-max))
      (eval-print-last-sexp))))

(el-get 'sync)

; Initialize autocomplete plugin
(add-to-list 'load-path "~/.emacs.d/ac-dict")
(require 'auto-complete-config)
(ac-config-default)

; Enable autopair
(require 'autopair)
(autopair-global-mode) ;; to enable in all buffers

(provide '.emacs)
;;; .emacs ends here
