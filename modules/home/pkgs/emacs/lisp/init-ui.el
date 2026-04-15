;;; init-ui.el --- UI configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Theme (doom-one), modeline, icons, font, line numbers, and dashboard.
;;; Code:

;; ---------- Theme -----------------------------------------------------------
(use-package doom-themes
  :demand t
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

;; ---------- Modeline --------------------------------------------------------
(use-package doom-modeline
  :demand t
  :config
  (doom-modeline-mode 1))

;; ---------- Icons -----------------------------------------------------------
;; doom-modeline auto-requires nerd-icons; no explicit declaration needed.
;; Run M-x nerd-icons-install-fonts on first launch to download icon fonts.

;; ---------- Font ------------------------------------------------------------
;; PragmataPro Mono Liga is a commercial font installed outside Nix.
;; If absent, Emacs silently falls back to the default monospace font.
;; Wrapped for daemon safety — no frame exists when the daemon starts.
(defun my/set-fonts (&optional _frame)
  "Set the default face to PragmataPro Mono Liga at height 170."
  (set-face-attribute 'default nil
		      :family "PragmataPro Mono Liga"
		      :height 160))
(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/set-fonts)
  (my/set-fonts))

;; ---------- Line numbers & visual polish ------------------------------------
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(global-hl-line-mode 1)
(pixel-scroll-precision-mode 1)

;; ---------- Dashboard -------------------------------------------------------
(use-package dashboard
  :demand t
  :config
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents   . 5)
			  (projects  . 5)
			  (agenda    . 5)))
  ;; Use initial-buffer-choice instead of dashboard-setup-startup-hook because
  ;; the startup hook can fire after the initial buffer is already selected,
  ;; making it unreliable.  initial-buffer-choice always wins.
  (setq initial-buffer-choice
	(lambda () (get-buffer-create dashboard-buffer-name))))

(provide 'init-ui)
;;; init-ui.el ends here
