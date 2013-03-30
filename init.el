;; (setq debug-on-error t)
;; (setq debug-on-message t)

(setq frame-title-format '(buffer-file-name "%f" ("%b")))
(tool-bar-mode -1)
(unless (display-graphic-p)
  (menu-bar-mode -1))

(load "~/.emacs.d/plugins/theme.el")

(defun add-subfolders-to-load-path (parent-dir)
  "Add subfolders to load path"
  (dolist (f (directory-files parent-dir))
    (let ((name (concat parent-dir f)))
      (when (and (file-directory-p name)
                 (not (equal f ".."))
                 (not (equal f ".")))
        (add-to-list 'load-path name)))))

(add-to-list 'load-path "~/.emacs.d/")
(add-to-list 'load-path "~/.emacs.d/plugins/")
(add-subfolders-to-load-path "~/.emacs.d/plugins/")

(defun main-startup ()
  (require 'undo-tree)
  (global-undo-tree-mode)

  (setq evil-want-C-u-scroll t)
  (setq show-paren-delay 0)
  (show-paren-mode)

  (require 'evil)
  (evil-mode 1)
  (evil-define-command repeat-no-move (&optional count)
    :repeat ignore
    (interactive)
    (evil-repeat count t))
  (setup-compile-command)

  (evil-define-command repeat-and-next-line (&optional count)
    :repeat ignore
    (interactive)
    (repeat-no-move count)
    (next-line))

  (make-escape-quit)
  (add-custom-evil-bindings)

  (require 'helm-config)
  (helm-mode 1)

  (require 'redshank-loader)

  (eval-after-load "redshank-loader"
    `(redshank-setup '(lisp-mode-hook
                       slime-repl-mode-hook) t))

  (load-language-modes)
  (load-version-control)

  (require 'autopair)
  (autopair-global-mode) ;; enable autopair in all buffers

  (autoload 'icy-mode "icicles"
    "Turn on icicles completion." t)
  (icy-mode 1)

  (require 'whitespace)

  (add-hook 'c-mode-hook 'smart-tabs-mode-enable)
  (add-hook 'javascript-mode-hook 'smart-tabs-mode-enable)
  (add-hook 'java-mode-hook
            '(lambda ()
               (custom-indent-mode)
               (smart-tabs-mode -1)))


  (setup-ac)
  (autoload 'enable-paredit-mode "paredit"
    "Turn on pseudo-structural editing of Lisp code."
    t)
  (setup-org-mode)

  (add-hook 'lisp-mode-hook 'all-lisp-mode)
  (add-hook 'emacs-lisp-mode-hook 'all-lisp-mode)

  (setup-smooth-scroll))

(add-hook 'emacs-startup-hook
          'main-startup)

(defun make-escape-quit ()
  (define-key evil-normal-state-map [escape] 'keyboard-quit)
  (define-key evil-visual-state-map [escape] 'keyboard-quit)
  (define-key evil-replace-state-map [escape] 'keyboard-quit)
  (define-key evil-motion-state-map [escape] 'keyboard-quit)
  (define-key evil-operator-state-map [escape] 'keyboard-quit)
  (global-set-key [escape] 'keyboard-escape-quit)
  (global-set-key "\C-s" 'save-buffer)
  (define-key isearch-mode-map [escape] 'isearch-abort)
  (define-key minibuffer-local-map [escape] 'keyboard-escape-quit)
  (define-key minibuffer-local-filename-completion-map [escape] 'keyboard-escape-quit)
  (define-key minibuffer-local-filename-must-match-map [escape] 'keyboard-escape-quit)
  (define-key minibuffer-local-must-match-filename-map [escape] 'keyboard-escape-quit)
  (define-key minibuffer-local-shell-command-map [escape] 'keyboard-escape-quit)
  (define-key minibuffer-local-ns-map [escape] 'keyboard-escape-quit)
  (define-key minibuffer-local-completion-map [escape] 'keyboard-escape-quit)
  (define-key minibuffer-local-must-match-map [escape] 'keyboard-escape-quit)
  (define-key minibuffer-local-isearch-map [escape] 'keyboard-escape-quit))

(defun comment-current-line ()
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(defun add-custom-evil-bindings ()
  (define-key evil-normal-state-map ";" 'comment-current-line)
  (define-key evil-visual-state-map ";" 'comment-or-uncomment-region)
  (define-key evil-visual-state-map "\\c " 'comment-or-uncomment-region)
  (define-key evil-normal-state-map "\C-n" nil)
  (define-key evil-normal-state-map "\C-p" nil)
  (define-key evil-normal-state-map (kbd "C-M-q") 'my-indent-sexp)
  (define-key evil-insert-state-map (kbd "C-M-q") 'my-indent-sexp)
  (define-key evil-visual-state-map (kbd "C-M-q") 'my-indent-sexp)
  (define-key evil-normal-state-map (kbd ".") 'repeat-no-move)
  (define-key evil-normal-state-map (kbd ",") 'repeat-and-next-line))

(set-language-environment "utf-8")

(defun setup-slime ()
  (load (expand-file-name "~/quicklisp/slime-helper.el"))
  (setq slime-lisp-implementations
        '((ccl64 ("/usr/bin/ccl64" "-K" "'utf-8-unix") :coding-system utf-8-unix)
          (sbcl ("/usr/bin/sbcl") :coding-system utf-8-unix)
          (ccl ("/usr/bin/ccl" "-K" "'utf-8-unix") :coding-system utf-8-unix)))

  (add-to-list 'load-path "/usr/share/emacs/site-lisp/slime/")
  (require 'slime)
  (setq slime-net-coding-system 'utf-8-unix)
  (slime-setup '(slime-fancy)))

(defun setup-ac ()
  (setq ac-use-menu-map t)
  (require 'auto-complete-config)
  (add-to-list 'ac-dictionary-directories "~/.emacs.d/plugins/ac-install/ac-dict")
  (ac-config-default)
  (global-auto-complete-mode t)
  (add-hook 'python-mode-hook 'inferior-python-mode)
  (eval-after-load "auto-complete"
    '(progn
       (setup-slime)
       (require 'ac-slime)
       (set-up-slime-ac)
       (add-hook 'slime-mode-hook 'set-up-slime-ac)
       (add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
       (add-to-list 'ac-modes 'slime-repl-mode)
       (add-to-list 'ac-modes 'lisp-mode)
       (add-to-list 'ac-modes 'common-lisp-mode)
       (add-to-list 'ac-modes 'slime-mode)
       (setq ac-completing-map
             (let ((map (make-sparse-keymap)))
               (define-key map [escape] 'leave-ac-mode)
               (define-key map "\t" 'ac-expand)
               (define-key map [tab] 'ac-expand)
               (define-key map "\r" 'ac-complete)
               (define-key map [return] 'ac-complete)
               (define-key map [down] 'ac-next)
               (define-key map [up] 'ac-previous)
               map)))))

(defun leave-ac-mode ()
  (message "Leaving ac mode.")
  (ac-stop)
  (keyboard-quit)
  (keyboard-escape-quit)
  (normal-mode))

(defun setup-org-mode ()
  (add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))
  (global-font-lock-mode 1)

  (add-hook 'org-mode-hook
            '(lambda ()
               (setq evil-auto-indent nil)
               (setq whitespace-style
                     (quote
                      (face tabs spaces space-before-tab newline
                            indentation empty space-after-tab space-mark
                            tab-mark))))))

(defun my-indent-sexp ()
  (interactive)
  (save-excursion
    (if (equal (string (following-char)) ")")
        (progn
          (forward-char)
          (backward-sexp))
      (if (equal (string (preceding-char)) ")")
          (backward-sexp)))
    (indent-sexp)))

(defun load-language-modes ()
  (require 'haskell-mode)
  (require 'lua-mode)
  (require 'pure-mode)
  (require 'sclang)
  (require 'markdown-mode))

(defun load-version-control ()
  (require 'monky)
  ;; Available only on mercurial versions 1.9 or higher
  (setq monky-process-type 'cmdserver)
  (require 'magit))

(setq auto-mode-alist (cons '("wscript" . python-mode) auto-mode-alist))
(setq c-default-style (quote ((java-mode . "java")
                              (awk-mode . "awk")
                              (other . "linux"))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-image-file-mode t)
 '(auto-save-file-name-transforms (quote ((".*" "~/.emacs.d/autosaves/\\1" t))))
 '(backup-directory-alist (quote ((".*" . "~/.emacs.d/backups/"))))
 '(backward-delete-char-untabify-method nil)
 '(blink-cursor-mode nil)
 '(compile-command "waf build")
 '(evil-cross-lines t)
 '(evil-want-C-u-scroll t)
 '(follow-auto t)
 '(global-whitespace-mode t)
 '(icicle-isearch-complete-keys (quote ([C-M-tab] [(control meta 105)] [M-tab])))
 '(ido-create-new-buffer (quote always))
 '(ido-enable-flex-matching t)
 '(ido-enable-prefix t)
 '(ido-enter-matching-directory (quote first))
 '(ido-everywhere t)
 '(ido-mode (quote file) nil (ido))
 '(image-dired-append-when-browsing t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(org-agenda-files (quote ("~/Documents/todo.txt")))
 '(python-python-command "python2")
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 ;; '(show-trailing-whitespace t) ; Completion buffers always look terrible....
 '(tab-always-indent (quote complete))
 '(tool-bar-mode nil)
 '(x-select-enable-clipboard t))

(defun setup-yasnippet ()
  (require 'yasnippet)
  (yas/initialize)
  (yas/load-directory "~/.emacs.d/snippets")
  (setq yas/snippet-dirs '("~/.emacs.d/snippets")))

(setup-yasnippet)

(setq whitespace-style
      (quote (face tabs spaces space-before-tab indentation
                   space-after-tab space-mark tab-mark)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(whitespace-empty ((t (:background "grey5" :foreground "grey5"))))
 '(whitespace-hspace ((t (:foreground "darkgray"))))
 '(whitespace-indentation ((t (:foreground "grey10"))))
 '(whitespace-line ((t (:foreground "violet"))))
 '(whitespace-space ((t (:foreground "grey10"))))
 '(whitespace-space-after-tab ((t (:foreground "grey10"))))
 '(whitespace-space-before-tab ((t (:foreground "grey10"))))
 '(whitespace-tab ((t (:foreground "grey10")))))

(add-hook 'slime-repl-mode-hook
          '(lambda ()
             (autopair-mode -1)
             (whitespace-mode t)
             (electric-pair-mode -1)))

(defun all-lisp-mode ()
  (setq indent-tabs-mode nil)
  (setq evil-word "[:word:]_-")
  (enable-paredit-mode)
  (custom-indent-mode))

(defun setup-language-indents ()
  (setq js-indent-level 2)
  (add-hook 'python-mode-hook
            '(lambda ()
               (setq indent-tabs-mode nil)
               (setq evil-shift-width 4)))
  (add-hook 'c-mode-common-hook 'std-indent-mode)
  (add-hook 'lisp-mode-hook 'custom-indent-mode))



(defun std-indent-mode ()
  (interactive)
  (setq c-basic-offset 4)
  (c-set-offset 'case-label '+)
  (setq tab-width 4)
  (setq standard-indent 4)
  (setq tab-stop-list (quote (4 8 12 16 20 24 28)))
  (setq evil-shift-width 4))

(defun custom-indent-mode ()
  (interactive)
  (c-set-offset 'case-label '+)
  (setq c-basic-offset 2)
  (setq tab-width 2)
  (setq standard-indent 2)
  (setq tab-stop-list (quote (2 4 6 8 10 12 14 16 18 20 22 24 26 28 30)))
  (setq evil-shift-width 2))

(setf indent-line-function 'insert-tab)

(defun cleanup ()
  (interactive)
  (whitespace-cleanup)
  (delete-trailing-whitespace))

(defvar hexcolour-keywords
  '(("#[[:xdigit:]]\\{6\\}"
     (0 (put-text-property (match-beginning 0)
                           (match-end 0)
                           'face (list :background
                                       (match-string-no-properties 0)))))))

(defun hexcolour-add-to-font-lock ()
  (font-lock-add-keywords nil hexcolour-keywords))

(when (display-graphic-p)
  (add-hook 'emacs-lisp-mode-hook 'hexcolour-add-to-font-lock))

(defun setup-compile-command ()
  (define-key evil-normal-state-map (kbd "C-c k") 'compile)
  (define-key evil-normal-state-map (kbd "C-c C-k") 'compile))

(defun setup-smooth-scroll ()
  ;; scroll one line at a time (less "jumpy" than defaults)
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
  ;; don't accelerate scrolling
  ;; (setq mouse-wheel-progressive-speed nil)
  ;; scroll window under mouse
  (setq mouse-wheel-follow-mouse 't)
  ;; keyboard scroll one line at a time
  (setq scroll-step 1))

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(defun add-ac-mode-hook ()
  (add-hook 'auto-complete-mode-hook
          '(lambda ()
             (setq ac-completing-map
                   (let ((map (make-sparse-keymap)))
                     (define-key map [escape] 'leave-ac-mode)
                     (define-key map "\t" 'ac-expand)
                     (define-key map [tab] 'ac-expand)
                     (define-key map "\r" 'ac-complete)
                     (define-key map [return] 'ac-complete)
                     (define-key map [down] 'ac-next)
                     (define-key map [up] 'ac-previous)
                     map)))))

(defun setup-indents()
  (require 'smart-tabs-mode)
  (setup-language-indents)
  (smart-tabs-advice c-indent-line c-basic-offset)
  (smart-tabs-advice c-indent-region c-basic-offset)
  (add-hook 'c-mode-hook 'smart-tabs-mode-enable)
  (add-hook 'javascript-mode-hook 'smart-tabs-mode-enable)
  (add-hook 'java-mode-hook
            '(lambda ()
               (custom-indent-mode)
               (smart-tabs-mode -1))))

(setup-indents)
