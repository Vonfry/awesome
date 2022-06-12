(require 'xdg)
(setq work-dir default-directory
      ci-dir (getenv "CI_PROJECT_DIR")
      build-dir (expand-file-name ".build" ci-dir)
      cache-dir (xdg-cache-home))
(message "emacs version: %s" emacs-version)
(message "current work dir: %s" work-dir)
(message "ci dir: %s" ci-dir)
(message "build dir: %s" build-dir)
(message "cache dir: %s" cache-dir)

(unless (string= ci-dir work-dir)
  (cd ci-dir)
  (message "change work dir to: %s" ci-dir))

(setq-default package-user-dir (expand-file-name "emacs/packages" cache-dir)
              org-id-locations-file (expand-file-name "emacs/id" cache-dir)
              +org-roam-files (directory-files-recursively "." "\\.org$" t))

(dolist (dir (list build-dir cache-dir
                   (file-name-directory org-id-locations-file)))
  (unless (file-exists-p dir)
    (make-directory dir t)))

(require 'org)
(require 'org-id)
(org-id-update-id-locations (directory-files-recursively ci-dir "\\.org\\'" t))

(setq-default org-roam-directory ci-dir)

(require 'org-roam)
(require 'org-roam-export)

(message "org version: %s" (org-version))
(message "org-roam version: %s" (org-roam-version))

(org-roam-setup)

(dolist (file +org-roam-files)
  (let* ((file-export (file-name-with-extension file "html"))
         (file-moved (expand-file-name file-export build-dir))
         (file-moved-dir (expand-file-name (file-name-directory file-moved))))
    (with-temp-buffer
      (find-file file)
      (org-html-export-to-html))
    (unless (file-exists-p file-moved-dir)
      (make-directory file-moved-dir t))
    (rename-file file-export file-moved t)))

(let* ((target-file (expand-file-name "index.html"  build-dir))
       (source-file (expand-file-name "readme.html" build-dir)))
  (unless (file-exists-p target-file)
    (make-symbolic-link target-file source-file)))
