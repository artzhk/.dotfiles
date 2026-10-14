;; TODO: I'm not sure if it does something though...
(setq gc-cons-threshold (* 64 1024 1024)       ; tune by doubling, see note
      read-process-output-max (* 4 1024 1024)  ; bigger pipe reads (LSP, rg)
      process-adaptive-read-buffering nil
      bidi-inhibit-bpa t
      bidi-paragraph-direction 'left-to-right)
(global-so-long-mode 1)  

(require 'package)
;; Any add to list for package-archives (to add marmalade or melpa) goes here
(add-to-list 'package-archives 
    '("MELPA" .
      "https://melpa.org/packages/"))
(add-to-list 'package-archives 
    '("STABLE-MELPA" .
      "https://stable.melpa.org/packages/"))
(package-initialize)
