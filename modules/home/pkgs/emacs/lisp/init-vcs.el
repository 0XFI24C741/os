;;; init-vcs.el --- Version control integration -*- lexical-binding: t; -*-
;;; Commentary:
;; Magit for Git porcelain and diff-hl for fringe change indicators.
;;; Code:

;; ---------- Magit --------------------------------------------------------------
(use-package magit
  :bind ("C-x g" . magit-status))

;; ---------- diff-hl (gutter indicators) ----------------------------------------
(use-package diff-hl
  :demand t
  :config
  (global-diff-hl-mode)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(provide 'init-vcs)
;;; init-vcs.el ends here
