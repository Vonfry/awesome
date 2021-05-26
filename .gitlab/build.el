(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)

(package-install 'org-roam)

(setq CI_DIR (getenv "CI_PROJECT_PATH")
      build_dir (expand-file-name ".build" CI_DIR)
      output_path (expand-file-name "roam.svg" build_dir))
(print (concat "CI DIR: " CI_DIR))

(setq-default org-roam-graph-viewer
  (lambda (file)
    (rename-file file output_path)))

(require 'org-roam)

(org-roam-graph)
