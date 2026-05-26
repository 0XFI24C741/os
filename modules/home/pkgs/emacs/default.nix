{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;

    extraPackages =
      epkgs: with epkgs; [
        cmake-mode
        company
        consult
        dockerfile-mode
        go-mode
        gruber-darker-theme
        lua-mode
        magit
        marginalia
        markdown-mode
        move-text
        multiple-cursors
        nix-mode
        orderless
        org-cliplink
        paredit
        rainbow-delimiters
        rust-mode
        toml-mode
        typescript-mode
        vertico
        which-key
        yaml-mode
        yasnippet
      ];
  };

  home.file.".emacs.d/early-init.el".text = ''
    ;;; early-init.el --- Startup defaults -*- lexical-binding: t; -*-

    (setq package-enable-at-startup nil
          inhibit-default-init t
          frame-inhibit-implied-resize t)

    (menu-bar-mode -1)
    (when (fboundp 'tool-bar-mode)
      (tool-bar-mode -1))
    (when (fboundp 'scroll-bar-mode)
      (scroll-bar-mode -1))
  '';

  home.file.".emacs.d/init.el".text = ''
    ;;; init.el --- Small personal Emacs config -*- lexical-binding: t; -*-

    (setq custom-file (locate-user-emacs-file "custom.el"))

    (setq inhibit-startup-screen t
          initial-scratch-message nil
          ring-bell-function 'ignore
          use-short-answers t
          confirm-kill-emacs 'y-or-n-p
          require-final-newline t
          sentence-end-double-space nil
          compilation-scroll-output t)

    (setq-default tab-width 2
                  fill-column 100
                  indent-tabs-mode nil)

    (dolist (dir '("backups" "auto-save"))
      (make-directory (locate-user-emacs-file dir) t))

    (setq backup-directory-alist `(("." . ,(locate-user-emacs-file "backups")))
          auto-save-file-name-transforms `((".*" ,(locate-user-emacs-file "auto-save/") t))
          create-lockfiles nil)

    (save-place-mode 1)
    (savehist-mode 1)
    (recentf-mode 1)
    (global-auto-revert-mode 1)
    (delete-selection-mode 1)
    (electric-pair-mode 1)
    (show-paren-mode 1)
    (column-number-mode 1)

    (when (display-graphic-p)
      (when (member "Fantasque Sans Mono" (font-family-list))
        (set-face-attribute 'default nil :family "Fantasque Sans Mono" :height 150)))

    (require 'gruber-darker-theme)
    (load-theme 'gruber-darker t)

    ;;; Completion
    (require 'consult)
    (require 'marginalia)
    (require 'orderless)
    (require 'vertico)
    (require 'which-key)

    (vertico-mode 1)
    (marginalia-mode 1)
    (which-key-mode 1)

    (setq completion-styles '(orderless basic)
          completion-category-defaults nil
          completion-category-overrides '((file (styles basic partial-completion))))

    (global-set-key (kbd "C-s") #'consult-line)
    (global-set-key (kbd "C-c h b") #'consult-buffer)
    (global-set-key (kbd "C-c h f") #'project-find-file)
    (global-set-key (kbd "C-c h g") #'consult-ripgrep)
    (global-set-key (kbd "C-c h r") #'consult-recent-file)
    (global-set-key (kbd "M-y") #'consult-yank-pop)

    ;;; Editing
    (require 'company)
    (require 'move-text)
    (require 'multiple-cursors)
    (require 'yasnippet)

    (global-company-mode 1)
    (setq company-idle-delay 0.15
          company-minimum-prefix-length 2
          company-tooltip-align-annotations t)

    (yas-global-mode 1)

    (global-set-key (kbd "C-S-c C-S-c") #'mc/edit-lines)
    (global-set-key (kbd "C->") #'mc/mark-next-like-this)
    (global-set-key (kbd "C-<") #'mc/mark-previous-like-this)
    (global-set-key (kbd "C-c C-<") #'mc/mark-all-like-this)

    (global-set-key (kbd "M-p") #'move-text-up)
    (global-set-key (kbd "M-n") #'move-text-down)

    (defun al/duplicate-line ()
      "Duplicate the current line without disturbing point's column."
      (interactive)
      (let ((column (current-column))
            (line (or (thing-at-point 'line t) "")))
        (end-of-line)
        (newline)
        (insert (string-remove-suffix "\n" line))
        (move-to-column column)))

    (global-set-key (kbd "C-,") #'al/duplicate-line)

    (defun al/unfill-paragraph ()
      "Turn the current paragraph into one long line."
      (interactive)
      (let ((fill-column most-positive-fixnum))
        (fill-paragraph)))

    (global-set-key (kbd "C-c M-q") #'al/unfill-paragraph)

    (defun al/copy-buffer-file-name ()
      "Copy the current file name, or dired directory, to the kill ring."
      (interactive)
      (let ((name (if (eq major-mode 'dired-mode)
                      default-directory
                    buffer-file-name)))
        (when name
          (kill-new name)
          (message "%s" name))))

    (global-set-key (kbd "C-c p f") #'al/copy-buffer-file-name)

    (defun al/insert-timestamp ()
      "Insert a compact local timestamp."
      (interactive)
      (insert (format-time-string "(%Y%m%d-%H%M%S)")))

    (global-set-key (kbd "C-x p d") #'al/insert-timestamp)

    (defun al/prog-mode-defaults ()
      (display-line-numbers-mode 1)
      (setq show-trailing-whitespace t)
      (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

    (add-hook 'prog-mode-hook #'al/prog-mode-defaults)
    (add-hook 'conf-mode-hook #'al/prog-mode-defaults)
    (add-hook 'text-mode-hook #'visual-line-mode)

    (defun al/lisp-mode-defaults ()
      (paredit-mode 1)
      (rainbow-delimiters-mode 1))

    (require 'paredit)
    (require 'rainbow-delimiters)

    (dolist (hook '(emacs-lisp-mode-hook
                    lisp-mode-hook
                    scheme-mode-hook))
      (add-hook hook #'al/lisp-mode-defaults))

    (add-hook 'emacs-lisp-mode-hook #'eldoc-mode)
    (add-hook 'emacs-lisp-mode-hook
              (lambda ()
                (local-set-key (kbd "C-c C-j") #'eval-print-last-sexp)))

    ;;; Git
    (require 'magit)

    (global-set-key (kbd "C-c m s") #'magit-status)
    (global-set-key (kbd "C-c m l") #'magit-log-buffer-file)

    ;;; Dired
    (require 'dired-x)
    (setq dired-dwim-target t
          dired-listing-switches "-alh --group-directories-first"
          dired-mouse-drag-files t
          dired-omit-files (concat dired-omit-files "\\|^\\..+$"))

    (add-hook 'dired-mode-hook #'dired-hide-details-mode)

    ;;; Org
    (setq org-directory (expand-file-name "~/org")
          org-agenda-files (list org-directory)
          org-startup-indented t
          org-hide-emphasis-markers t
          org-log-done 'time)

    (make-directory org-directory t)

    (global-set-key (kbd "C-x a") #'org-agenda)
    (global-set-key (kbd "C-c c") #'org-capture)
    (global-set-key (kbd "C-c C-x j") #'org-clock-jump-to-current-clock)

    (setq org-capture-templates
          `(("t" "Task" entry
             (file ,(expand-file-name "inbox.org" org-directory))
             "* TODO %?\n  %U\n")))

    (with-eval-after-load 'org
      (require 'org-cliplink)
      (define-key org-mode-map (kbd "C-c C-l") #'org-cliplink))

    ;;; Languages
    (autoload 'cmake-mode "cmake-mode" nil t)
    (autoload 'dockerfile-mode "dockerfile-mode" nil t)
    (autoload 'go-mode "go-mode" nil t)
    (autoload 'lua-mode "lua-mode" nil t)
    (autoload 'markdown-mode "markdown-mode" nil t)
    (autoload 'nix-mode "nix-mode" nil t)
    (autoload 'rust-mode "rust-mode" nil t)
    (autoload 'toml-mode "toml-mode" nil t)
    (autoload 'typescript-mode "typescript-mode" nil t)
    (autoload 'yaml-mode "yaml-mode" nil t)

    (add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-mode))
    (add-to-list 'auto-mode-alist '("\\.dockerfile\\'" . dockerfile-mode))
    (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))
    (add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))
    (add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-mode))
    (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))
    (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
    (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
    (add-to-list 'auto-mode-alist '("\\.toml\\'" . toml-mode))
    (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . typescript-mode))
    (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode))

    ;;; Compilation
    (require 'ansi-color)

    (defun al/colorize-compilation-buffer ()
      (ansi-color-apply-on-region compilation-filter-start (point)))

    (add-hook 'compilation-filter-hook #'al/colorize-compilation-buffer)

    (load custom-file 'noerror)
  '';
}
