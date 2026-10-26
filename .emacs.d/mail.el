;; Read: IMAP4 over implicit TLS
(setq gnus-select-method
      '(nnimap "mail"
               (nnimap-address "imap.example.com")
               (nnimap-server-port 993)
               (nnimap-stream ssl))

      auth-sources '("/mnt/gpg/authinfo.gpg")

      ;; Send: SMTP submission over implicit TLS
      send-mail-function    'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-server  "smtp.example.com"
      smtpmail-smtp-service 465
      smtpmail-stream-type  'ssl
      user-mail-address     "artemdev@worldofmail.com")
