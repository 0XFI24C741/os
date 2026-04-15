;;; init-editing.el --- Editing enhancements -*- lexical-binding: t; -*-
;;; Commentary:
;; Which-key (keybinding hints), electric pairs, rainbow delimiters, undo tree,
;; move-text, expand-region, and sensible built-in defaults.
;;; Code:

;; ---------- Which-key (keybinding discovery) ---------------------------------
(use-package which-key
  :demand t
  :config
  (setq which-key-idle-delay 0.5)
  (which-key-mode 1))

;; ---------- Electric pairs ---------------------------------------------------
(add-hook 'prog-mode-hook #'electric-pair-mode)

;; ---------- Rainbow delimiters -----------------------------------------------
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; ---------- Vundo (visual undo tree) -----------------------------------------
(use-package vundo
  :bind ("C-x u" . vundo))

;; ---------- Move-text (move lines up/down) -----------------------------------
(use-package move-text
  :bind (("M-<up>"   . move-text-up)
         ("M-<down>" . move-text-down)))

;; ---------- Expand-region ----------------------------------------------------
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; ---------- Built-in settings ------------------------------------------------
;; Whitespace cleanup on save
(add-hook 'before-save-hook #'whitespace-cleanup)

;; Use short answers (y/n instead of yes/no)
(setq use-short-answers t)

;; Save place — remember cursor position in files
(save-place-mode 1)

;; Recent files — track recently opened files
(setq recentf-max-saved-items 50)
(recentf-mode 1)

;; Auto-revert — refresh buffers when files change on disk
(global-auto-revert-mode 1)

;; UTF-8 defaults
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")

(provide 'init-editing)
;;; init-editing.el ends here
