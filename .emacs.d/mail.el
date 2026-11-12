;; ~/.emacs.d/init.el
(setq gnus-select-method
      '(nnimap "main"
               ;; (nnimap-user "paste address here")
               (nnimap-address "imap.purelymail.com")
               (nnimap-server-port 993)
               (nnimap-stream ssl))
      gnus-permanently-visible-groups ".*")

(setq send-mail-function    'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-server  "smtp.purelymail.com"
      smtpmail-smtp-service 465
      smtpmail-stream-type  'ssl
      ;; user-mail-address     "paste address here")
      )

(setq auth-sources (list  (format "/run/user/%d/secure-ramfs/gnupg/authinfo.gpg" (user-uid))))
(setq auth-source-save-behavior nil)
(setenv "GNUPGHOME" (format "/run/user/%d/secure-ramfs/gnupg" (user-uid)))
(setq gnus-permanently-visible-groups ".*")
