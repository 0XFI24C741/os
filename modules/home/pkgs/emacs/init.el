;;; init.el --- Main Emacs configuration entry point -*- lexical-binding: t; -*-
;;; Commentary:
;; Sets up package.el with MELPA/GNU/NonGNU archives, configures use-package,
;; adds lisp/ to load-path, and requires all configuration modules.
;;; Code:

;; ---------- Package archives ---------------------------------------------
(require 'package)
(setq package-archives
      '(("melpa"    . "https://melpa.org/packages/")
        ("gnu"      . "https://elpa.gnu.org/packages/")
        ("nongnu"   . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

;; Download archive metadata on first launch (prevents missing-package errors).
(unless package-archive-contents
  (package-refresh-contents))

;; ---------- use-package defaults -----------------------------------------
;; Install missing packages automatically; defer loading by default.
(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-always-defer t)

;; ---------- Load path for custom modules ---------------------------------
(add-to-list 'load-path
             (expand-file-name "lisp" user-emacs-directory))

;; ---------- Require configuration modules --------------------------------
(require 'init-ui)
(require 'init-completion)
(require 'init-editing)
(require 'init-coding)
(require 'init-org)
(require 'init-writing)
(require 'init-vcs)

(provide 'init)
;;; init.el ends here
