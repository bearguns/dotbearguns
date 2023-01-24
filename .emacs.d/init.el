(load-theme 'modus-vivendi)
(electric-pair-mode 1)
(electric-indent-mode 1)

;; Try to make our PATH match up for things like node executables
(setq exec-path (split-string (shell-command-to-string "bash -l -c 'echo -n $PATH'") ":"))
(setenv "PATH" (mapconcat 'identity exec-path ":"))

(tool-bar-mode -1)
(scroll-bar-mode -1)

;;; I prefer cmd key for meta
(setq mac-option-key-is-meta nil
      mac-command-key-is-meta t
      mac-command-modifier 'meta
      mac-option-modifier 'none)

;; Install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package
(straight-use-package 'use-package)

;; Configure use-package to use straight.el by default
(use-package straight
  :custom (straight-use-package-by-default t))

(use-package treesit-parser-manager
  :straight (treesit-parser-manager
             :host codeberg
             :repo "ckruse/treesit-parser-manager"
             :files ("*.el"))
  :commands (treesit-parser-manager-install-grammars
             treesit-parser-manager-update-grammars
             treesit-parser-manager-install-or-update-grammars
             treesit-parser-manager-remove-grammar)
  :custom
  (treesit-parser-manager-grammars
   '(("https://github.com/tree-sitter/tree-sitter-rust"
      ("tree-sitter-rust"))

     ("https://github.com/ikatyang/tree-sitter-toml"
      ("tree-sitter-toml"))

     ("https://github.com/tree-sitter/tree-sitter-typescript"
      ("tree-sitter-typescript/tsx" "tree-sitter-typescript/typescript"))

     ("https://github.com/tree-sitter/tree-sitter-javascript"
      ("tree-sitter-javascript"))

     ("https://github.com/tree-sitter/tree-sitter-css"
      ("tree-sitter-css"))

     ("https://github.com/serenadeai/tree-sitter-scss"
      ("tree-sitter-scss"))

     ("https://github.com/tree-sitter/tree-sitter-json"
      ("tree-sitter-json"))
     ("https://github.com/ikatyang/tree-sitter-vue"
      ("tree-sitter-vue"))))
  :config
  (add-to-list 'treesit-extra-load-path treesit-parser-manager-target-directory)
  :hook (emacs-startup . treesit-parser-manager-install-grammars))

(use-package emmet-mode)
(use-package web-mode
  :mode (("\\.html\\'" . web-mode))
  :hook ((web-mode . emmet-mode)))

(defun vue-mode-setup ()
  "Configure web-mode and LSP for VueJS development"
  ;; (setq-default web-mode-script-padding 0)
  ;; (setq-default web-mode-style-padding 0)
  ;; (setq-default web-mode-markup-indent-offset 2)
  ;; (setq-default web-mode-css-indent-offset 2)
  ;; (setq-default web-mode-code-indent-offset 2)
  ;; (setq-default web-mode-auto-pairs nil)
  (setq web-mode-script-padding 0)
  (setq web-mode-style-padding 0)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-auto-pairs nil))

(define-derived-mode vue-mode web-mode "Vue"
  "Web-mode derived mode for VueJS 3")

(add-hook 'vue-mode-hook 'vue-mode-setup)
(add-to-list 'auto-mode-alist '("\\.vue\\'" . vue-mode))
;; (add-hook 'editorconfig-after-apply-functions
;;           (lambda (props) 'vue-mode-setup))

;; Format code
(use-package apheleia
  :hook ((vue-mode . apheleia-mode)))

(setq tab-always-indent 'complete)

;; (use-package corfu
;;   :hook ((prog-mode . corfu-mode))
;;   :custom
;;   (corfu-auto t))
(use-package company
  :hook ((prog-mode . company-mode))
  :config
  (setq company-prefix 2
	company-idle-delay 0))

(with-eval-after-load 'eglot
  (setq eglot-events-buffer-size 0)
  ;;(setq eglot-send-changes-idle-time)
  (setq-default flymake-no-changes-timeout 1)
  (add-to-list 'eglot-stay-out-of 'eldoc)
  (add-to-list 'eglot-stay-out-of 'flymake)
  (defclass eglot-volar (eglot-lsp-server) ()
    :documentation "A custom class for volar")

  (cl-defmethod eglot-initialization-options ((server eglot-volar))
    "Passes through required volar initialization options"
    (let*
        ((serverPath (concat (string-trim (shell-command-to-string "npm config get prefix")) "/lib/node_modules/typescript/lib")))
      (list :typescript
            (list :tsdk serverPath)
            :languageFeatures
            (list :completion
                  (list :defaultTagNameCase "both"
                        :defaultAttrNameCase "kebabCase"
                        :getDocumentNameCasesRequest nil
                        :getDocumentSelectionRequest nil)
                  :diagnostics
                  (list :getDocumentVersionRequest nil))
            :documentFeatures
            (list :documentFormatting
                  (list :defaultPrintWidth 100
                        :getDocumentPrintWidthRequest nil)
                  :documentSymbol t
                  :documentColor t))))

  (add-to-list 'eglot-server-programs '(vue-mode . ("eslint-lsp" "--stdio")))
  ;; (add-to-list 'eglot-server-programs
  ;;              '(vue-mode . (eglot-volar "vue-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(typescript-ts-mode . (eglot-volar "vue-language-server" "--stdio"))))


