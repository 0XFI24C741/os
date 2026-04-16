;;; init-org.el --- Org-mode configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Org-mode GTD workflow (agenda, capture, refile), babel for literate
;; programming, plus org-modern and org-appear for visual polish.
;;; Code:

;; ---------- Org (built-in) --------------------------------------------------
(use-package org
  :ensure nil
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link))
  :custom
  ;; Directories
  (org-directory "~/org")
  (org-agenda-files '("~/org"))
  ;; Skip missing agenda files silently instead of prompting at startup —
  ;; dashboard's agenda item otherwise blocks on a hidden minibuffer prompt
  ;; when ~/org/ does not exist, leaving the frame unrendered until input.
  (org-agenda-skip-unavailable-files t)

  ;; TODO workflow
  (org-todo-keywords
   '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))

  ;; Capture templates
  (org-capture-templates
   '(("t" "Task" entry (file "~/org/inbox.org")
      "* TODO %?\n  %U\n  %a" :empty-lines 1)
     ("n" "Note" entry (file "~/org/notes.org")
      "* %?\n  %U" :empty-lines 1)
     ("j" "Journal" entry (file+datetree "~/org/journal.org")
      "* %?\n  %U" :empty-lines 1)))

  ;; Refile
  (org-refile-targets '((org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)

  ;; Visual
  (org-startup-indented t)
  (org-hide-leading-stars t)
  (org-ellipsis " ▾")
  (org-pretty-entities t)

  :config
  ;; Babel — load languages
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell      . t)
     (ruby       . t)
     (python     . t)))
  ;; Only skip confirmation for emacs-lisp blocks; prompt for shell/python/ruby.
  ;; NOTE: emacs-lisp can still run arbitrary commands (e.g. call-process,
  ;; shell-command), so only evaluate blocks from trusted org files.
  (setq org-confirm-babel-evaluate
        (lambda (lang _body)
          (not (string= lang "emacs-lisp")))))

;; ---------- Org-modern (visual enhancements) --------------------------------
(use-package org-modern
  :hook (org-mode . org-modern-mode))

;; ---------- Org-appear (reveal emphasis markers on cursor) ------------------
(use-package org-appear
  :hook (org-mode . org-appear-mode))

(provide 'init-org)
;;; init-org.el ends here
