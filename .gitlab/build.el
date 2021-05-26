(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)

(package-install 'org-roam)

(setq CI_DIR (getenv "CI_PROJECT_DIR")
      build_dir (expand-file-name ".build" CI_DIR)
      output_path (expand-file-name "roam.svg" build_dir))
(print (concat "CI DIR: " CI_DIR))

(make-directory build_dir t)

(setq-default org-roam-graph-viewer
  (lambda (file)
    (print (concat "graph file: " file))
    (print (concat "new file: " output_path))
    (copy-file file output_path t)))
(setq-default org-roam-directory CI_DIR
              org-roam-graphviz-extra-options '(("rankdir" . "LR")))

(require 'org-roam)

(org-roam-graph)
