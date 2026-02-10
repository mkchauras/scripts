;; export-agenda.el
(require 'org)
(require 'org-agenda)

;; Initialize package manager
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)  ;; If using package.el, otherwise use straight.el initialization

;; Function to force reinstall a package
(defun force-reinstall-package (pkg)
  "Force reinstall the specified package."
  (when (package-installed-p pkg)
    (package-delete (cadr (assq pkg package-alist)))) ;; Delete the package
  (package-refresh-contents) ;; Refresh package contents
  (package-install pkg)) ;; Reinstall the package

;; Example usage to reinstall htmlize
;;(force-reinstall-package 'htmlize)

;; Ensure htmlize is installed
(unless (package-installed-p 'htmlize)
  (package-refresh-contents)
  (package-install 'htmlize))
(require 'htmlize)



(setq org-agenda-files '("~/docs/scheduler/README.org"
			 "~/scripts/agenda/agenda.org"))  ; Adjust this to your org files

(setq org-agenda-span 'month)

;; Generate the agenda and export it to a file
(let ((output-file "/tmp/agenda.html"))  ; Change this to your desired output file
  (with-temp-buffer
    (org-agenda-list)
    ;;(org-batch-agenda "a")
    (org-agenda-write output-file)))
