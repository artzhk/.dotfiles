;; ~/.emacs.d/init.el
(setq gnus-select-method
      '(nnimap "purelymail"
               (nnimap-address "imap.purelymail.com")
               (nnimap-server-port 993)
               (nnimap-stream ssl)))

(setq send-mail-function    'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-server  "smtp.purelymail.com"
      smtpmail-smtp-service 465
      smtpmail-stream-type  'ssl
      user-mail-address     "artemdev@worldofmail.com")

(setq auth-source (format "/run/user/%d/secure-ramfs/gnupg/authinfo.gpg" (user-uid)))
(setenv "GNUPGHOME" (format "/run/user/%d/secure-ramfs/gnupg" (user-uid)))

