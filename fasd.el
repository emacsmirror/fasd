;;; fasd.el --- Emacs integration for the command-line productivity booster 'fasd'

;; Copyright (C) 2013 steckerhalter

;; Author: steckerhalter
;; URL: https://github.com/steckerhalter/emacs-fasd
;; Keywords: cli bash zsh autojump

;;; Commentary:

;; Hooks into to `find-file-hook' to add all visited files and directories to `fasd'.
;; Adds the function `fasd-find-file' to prompt and fuzzy complete available candidates

;;; Requirements:

;; `fasd' command line tool, see: https://github.com/clvv/fasd
;; `grizzl' for fuzzy completion

;;; Code:

(require 'grizzl)

;;;###autoload
(defun fasd-find-file (prefix &optional query)
  "Use fasd to open a file, or a directory with dired.
If PREFIX is non-nil consider only directories. QUERY can be
passed optionally to avoid the prompt."
  (interactive "P")
  (unless query (setq query (read-from-minibuffer "Fasd query: ")))
  (let* ((results
          (split-string
           (shell-command-to-string
            (concat "fasd -l" (if prefix " -d " " -a ") query)) "\n" t))
         (file (if (> (length results) 1)
                   (grizzl-completing-read "Fasd query: " (grizzl-make-index results))
                 (car results))))
    (if file
        (if (file-readable-p file)
            (if (file-directory-p file)
                (dired file)
              (find-file file))
          (message "Directory or file %s doesn't exist" file))
      (message "Fasd found nothing for query %s" query)
      )
    ))

;;;###autoload
(defun fasd-add-file-to-db ()
  "Add current file or directory to the Fasd database."
  (let ((file (if (string= major-mode "dired-mode")
                  dired-directory
                (buffer-file-name))))
    (start-process "*fasd*" nil "fasd" "--add" file)))

;;;###autoload
(add-hook 'find-file-hook 'fasd-add-file-to-db)
;;;###autoload
(add-hook 'dired-mode-hook 'fasd-add-file-to-db)

(provide 'fasd)
;;; fasd.el ends here
