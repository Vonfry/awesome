(require 'xdg)
(setq ci-dir (getenv "CI_PROJECT_DIR")
      build-dir (expand-file-name ".build" ci-dir)
      output-file (expand-file-name "roam.svg" build-dir)
      cache-dir (xdg-cache-home))
(message (concat "ci dir: " ci-dir))
(message (concat "build dir: " build-dir))
(message (concat "cache dir: " cache-dir))
(message (concat "output file: " output-file))

(when (file-exists-p output-file)
  (delete-file output-file))

(setq-default package-user-dir (expand-file-name "emacs/packages" cache-dir)
              org-id-locations-file (expand-file-name "emacs/id" cache-dir))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)

(package-install 'org)
(package-install 'org-roam)

(require 'org)
(require 'org-id)
(org-id-update-id-locations (directory-files-recursively ci-dir "\\.org$" t))

(setq-default org-roam-graph-viewer
  (lambda (file)
    (message "graph file: %s" file)
    (copy-file file output-file t)))
(setq-default org-roam-directory ci-dir
              org-roam-graph-extra-config '(("rankdir" . "LR")))

(require 'org-roam)

(message "org version: %s" (org-version))
(message "org-roam version: %s" (org-roam-version))

(find-file (expand-file-name "readme.org" ci-dir))

(org-roam-setup)
(setq graph-process (org-roam-graph))

(while (process-live-p graph-process))

(if (file-exists-p output-file)
    (message "output: %s" output-file)
  (progn
    (message "no output file from org-roam-graph. ")
    (message "process exit status: %d"
             (process-exit-status graph-process))
    (let ((tmp-file (car (directory-files temporary-file-directory t
                                          "\\.svg$"))))
      (copy-file tmp-file output-file t)
      (message "output: %s" output-file))))
