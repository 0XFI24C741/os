;;; init-completion.el --- Completion framework -*- lexical-binding: t; -*-
;;; Commentary:
;; Vertico (minibuffer), Orderless (matching), Marginalia (annotations),
;; Consult (search/navigation), Embark (actions), Corfu (in-buffer), Cape (backends).
;;; Code:

;; ---------- Vertico (vertical minibuffer completion) -----------------------
(use-package vertico
  :demand t
  :config
  (vertico-mode 1))

;; ---------- Orderless (flexible matching) ----------------------------------
(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((file (styles partial-completion)))))

;; ---------- Marginalia (rich annotations) ----------------------------------
(use-package marginalia
  :demand t
  :config
  (marginalia-mode 1))

;; ---------- Consult (search & navigation) ----------------------------------
(use-package consult
  :bind (("C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("M-s r" . consult-ripgrep)
         ("M-s f" . consult-find)
         ("M-y"   . consult-yank-pop)
         ("M-g g" . consult-goto-line)))

;; ---------- Embark (contextual actions) ------------------------------------
(use-package embark
  :bind (("C-."   . embark-act)
         ("C-;"   . embark-dwim)))

(use-package embark-consult
  :after (embark consult))

;; ---------- Corfu (in-buffer completion) -----------------------------------
(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  :config
  (global-corfu-mode 1))

;; ---------- Cape (completion-at-point extensions) --------------------------
(use-package cape
  :demand t
  :config
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

(provide 'init-completion)
;;; init-completion.el ends here
