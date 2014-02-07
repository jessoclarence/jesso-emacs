;;; package --- Jesso's init file

;;; Commentary:
; My experiments Sept 11, 2013

;;; Code:

;;; Code:
(set-default 'cursor-type 'bar)
; Set tabs to spaces
(setq indent-tabs-mode nil)

(toggle-scroll-bar -1)
; Show line numbers
(global-linum-mode 1)

; Start new line on proper indent
(define-key global-map (kbd "RET") 'newline-and-indent)

; Remove icon-bar
(tool-bar-mode -1)

; Delete trailing whitespace on file save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

; Highlight chars after 80 col limit
(require 'whitespace)
 (setq whitespace-style '(face empty tabs lines-tail trailing))
 (global-whitespace-mode t)

; Set font size
(set-face-attribute 'default nil :height 120)

; Higlight matching paren
(show-paren-mode 1)

(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

(defun recentf-ido-find-file ()
  "Find a recent file using Ido."
  (interactive)
  (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
    (when file
      (find-file file))))

(defun recentf-filtered-list (arg)
  "Return a filtered list of ARG recentf items."
    (recentf-apply-menu-filter
     recentf-menu-filter
     (mapcar 'recentf-make-default-menu-element
       (butlast recentf-list (- (length recentf-list) arg)))))

(defun recentf-list-submenus (arg)
  "Return a list of the recentf submenu names."
  (if (listp (cdar (recentf-filtered-list arg))) ; submenues exist
      (delq nil (mapcar 'car (recentf-filtered-list arg)))))

(defmacro recentf-list-entries (fn arg)
  "Return a list of ARG recentf menu entries as determined by FN.
When FN is `'car' return the menu entry names, when FN is `'cdr'
return the absolute file names."
  `(mapcar (lambda (x) (mapcar ,fn x))
     (if (recentf-list-submenus ,arg)
         (mapcar 'cdr (recentf-filtered-list ,arg))
       (list (recentf-filtered-list ,arg)))))

;; This function is not specific to recentf mode but is needed by
;; `recentf-minibuffer-dialog'.  I've also made enough use of it in
;; other contexts that I'm surprised it's not part of Emacs, and the
;; fact that it isn't makes me wonder if there's a preferred way of
;; doing what I use this function for.
(defun recentf-memindex (mem l)
  "Return the index of MEM in list L."
  (let ((mempos -1) ret)
    (while (eq ret nil)
      (setq mempos (1+ mempos))
      (when (equal (car l) mem) (setq ret mempos))
      (setq l (cdr l)))
    ret))

(defun recentf-minibuffer-dialog (arg)
  "Open the recentf menu via the minubuffer, with completion.
With positive prefix ARG, show the ARG most recent items.
Otherwise, show the default maximum number of recent items."
  (interactive "P")
  (let* ((num (prog1 (if (and (not (null arg))
            (> arg 0))
       (min arg (length recentf-list))
           recentf-max-menu-items)
    (and (not (null arg))
         (> arg (length recentf-list))
         (message "There are only %d recent items."
            (length recentf-list))
         (sit-for 2))))
   (menu (if (recentf-list-submenus num)
       (completing-read "Open recent: "
            (recentf-list-submenus num))))
   (i (recentf-memindex menu (recentf-list-submenus num)))
   (items (nth i (recentf-list-entries 'car num)))
   (files (nth i (recentf-list-entries 'cdr num)))
   (item (completing-read "Open recent: " items))
   (j (recentf-memindex item items))
   (file (nth j files)))
    (funcall recentf-menu-action file))) ; find-file by default
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

;; Load Perspective
(require 'perspective)
;; Toggle the perspective mode
(persp-mode)

;;; initialize stuff that were el-get installed
(autopair-global-mode)
(add-to-list 'auto-mode-alist (cons (rx ".js" eos) 'js2-mode))

(require 'git-gutter-fringe)
(global-git-gutter-mode 1)

(global-set-key [(meta x)] (lambda ()
                             (interactive)
                             (or (boundp 'smex-cache)
                                 (smex-initialize))
                             (global-set-key [(meta x)] 'smex)
                             (smex)))

(global-set-key [(shift meta x)] (lambda ()
                                   (interactive)
                                   (or (boundp 'smex-cache)
                                       (smex-initialize))
                                   (global-set-key [(shift meta x)] 'smex-major-mode-commands)
                                   (smex-major-mode-commands)))

; Enable jedi for python
(add-hook 'python-mode-hook 'auto-complete-mode)
(add-hook 'python-mode-hook 'jedi:ac-setup)
(setq jedi:complete-on-dot t)

; Enable flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

; Initialize autocomplete plugin
(add-to-list 'load-path "~/.emacs.d/ac-dict")
(require 'auto-complete-config)
(ac-config-default)

; Higlight values
(add-hook 'python-mode-hook 'highlight-symbol-mode)
(add-hook 'js2-mode-hook 'highlight-symbol-mode)

(require 'color-theme)
    (color-theme-initialize)
    (color-theme-ld-dark)
; Autocomplete should preserve caps
(setq ac-ignore-case nil)

; Mode line
(setq sml/theme 'respectful)
(sml/setup)

; yasnippet

(require 'yasnippet)
(setq yas-snippet-dirs
      '("~/.emacs.d/el-get/yasnippet/plugins/yasnippet/snippets"))
(yas-global-mode 1)

;;; Custom code written by me

; Create a func in python that adheres to google py style guide
(defun jesso-documented-py-func (func-name)
  (interactive "sEnter function name: ")
  (setq args-list (list))
  (setq while-test t)
  (while (eq while-test t)
    (setq args-name (read-from-minibuffer "Arg name"))
    (if (string= "" args-name)
      (setq while-test nil)
      (add-to-list 'args-list args-name)))
  (reverse args-list)
  (setq final-string (concat "def " func-name "("))
  (setq i 0)
  (dolist (arg-name args-list)
    (progn
      (if (> i 0)
        (setq final-string (concat final-string ", ")))
      (setq final-string (concat final-string arg-name))
      (incf i)))
  (setq final-string (concat final-string "):\n" ))
  (insert-string final-string))

(provide '.emacs)
;;; .emacs ends here
