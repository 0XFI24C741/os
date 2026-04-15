;;; init-writing.el --- Writing and prose tools -*- lexical-binding: t; -*-
;;; Commentary:
;; Markdown editing, centered prose with olivetti, and spell checking
;; via flyspell (aspell backend).
;;; Code:

;; ---------- Markdown-mode ----------------------------------------------------
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

;; ---------- Olivetti (centered writing) --------------------------------------
(use-package olivetti
  :hook ((org-mode      . olivetti-mode)
         (markdown-mode . olivetti-mode))
  :custom
  (olivetti-body-width 80))

;; ---------- Flyspell (spell checking, built-in) ------------------------------
;; text-mode-hook also fires for org-mode (org derives from text-mode).
;; Flyspell may flag org syntax (e.g. #+TITLE, :PROPERTIES:) as misspelled;
;; this is acceptable — ispell-skip-region-alist can be tuned if needed.
(use-package flyspell
  :ensure nil
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)))

(provide 'init-writing)
;;; init-writing.el ends here
