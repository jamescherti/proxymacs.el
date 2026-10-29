;;; proxymacs.el --- HTTP/HTTPS or SOCKS proxy configuration -*- lexical-binding: t; -*-

;; Copyright (C) 2026 James Cherti

;; Author: James Cherti <https://www.jamescherti.com/contact/>
;; Version: 0.9.9
;; URL: https://github.com/jamescherti/proxymacs.el
;; Keywords: convenience
;; Package-Requires: ((emacs "25.1"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; The proxymacs Emacs package simplifies HTTP, HTTPS, and SOCKS proxy
;; configuration. It supports HTTP/HTTPS proxies and SOCKS4, SOCKS4a, and
;; SOCKS5.

;;; Code:

(defgroup proxymacs nil
  "Simplify proxy configuration."
  :group 'convenience
  :prefix "proxymacs-"
  :link '(url-link
          :tag "Github"
          "https://github.com/jamescherti/proxymacs.el"))

(defcustom proxymacs-proxy-type nil
  "The active proxy type."
  :type '(choice (const :tag "None" nil)
                 (const :tag "HTTP and HTTPS proxy" http)
                 (const :tag "SOCKS proxy" socks))
  :group 'proxymacs)

(defcustom proxymacs-verbose nil
  "Enable displaying verbose messages."
  :type 'boolean
  :group 'proxymacs)

(defcustom proxymacs-http-host nil
  "HTTP proxy server hostname or IP address."
  :type '(choice (const :tag "None" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-http-port 8080
  "HTTP proxy server port."
  :type '(choice integer string)
  :group 'proxymacs)

(defcustom proxymacs-https-host nil
  "HTTPS proxy server hostname or IP address.
When nil, `proxymacs-http-host' is used."
  :type '(choice (const :tag "Use `proxymacs-http-host'" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-https-port nil
  "HTTPS proxy server port.
When nil, `proxymacs-http-port' is used."
  :type '(choice (const :tag "Use `proxymacs-http-port'" nil)
                 integer
                 string)
  :group 'proxymacs)

(defcustom proxymacs-http-realm "Proxy"
  "Authentication realm used by the HTTP proxy."
  :type '(choice (const :tag "None" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-http-user nil
  "Username for proxy authentication, or nil."
  :type '(choice (const :tag "None" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-http-password nil
  "Password for proxy authentication, or nil."
  :type '(choice (const :tag "None" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-https-realm nil
  "Authentication realm used by the HTTPS proxy.
When nil, `proxymacs-http-realm' is used."
  :type '(choice (const :tag "Use `proxymacs-http-realm'" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-https-user nil
  "Username for HTTPS proxy authentication.
When nil, `proxymacs-http-user' is used."
  :type '(choice (const :tag "Use `proxymacs-http-user'" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-https-password nil
  "Password for HTTPS proxy authentication.
When nil, `proxymacs-http-password' is used."
  :type '(choice (const :tag "Use `proxymacs-http-password'" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-http-no-proxy nil
  "Regexp or list of regexps matching hosts that bypass the Emacs URL proxy.

For example:
\"^\\\\(localhost\\\\|127\\\\.0\\\\.0\\\\.1\\\\|192\\\\.168\\\\..*\\\\)\""
  :type '(choice (const :tag "None" nil)
                 regexp
                 (repeat regexp))
  :group 'proxymacs)

(defcustom proxymacs-socks-host nil
  "SOCKS proxy server hostname or IP address."
  :type '(choice (const :tag "None" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-socks-port 1080
  "SOCKS proxy server port."
  :type '(choice integer string)
  :group 'proxymacs)

(defcustom proxymacs-socks-version 5
  "SOCKS protocol version (4, 4a, or 5)."
  :type '(choice (const :tag "SOCKS5" 5)
                 (const :tag "SOCKS4a" 4a)
                 (const :tag "SOCKS4" 4))
  :group 'proxymacs)

(defcustom proxymacs-socks-user nil
  "Username for SOCKS proxy authentication, or nil."
  :type '(choice (const :tag "None" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-socks-password nil
  "Password for SOCKS proxy authentication, or nil."
  :type '(choice (const :tag "None" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-socks-no-proxy nil
  "Regexp or list of regexps matching hosts that bypass the SOCKS proxy.

For example:
\"^\\\\(localhost\\\\|127\\\\.0\\\\.0\\\\.1\\\\|192\\\\.168\\\\..*\\\\)\""
  :type '(choice (const :tag "None" nil)
                 regexp
                 (repeat regexp))
  :group 'proxymacs)

(defvar url-proxy-services)
(defvar url-http-proxy-basic-auth-storage)
(defvar url-gateway-method)
(defvar socks-server)
(defvar socks-noproxy)
(defvar socks-username)
(defvar socks-password)

(defun proxymacs--message (&rest args)
  "Display a message with the same ARGS arguments as `message'."
  (apply #'message (concat "[proxymacs] " (car args)) (cdr args)))

(defmacro proxymacs--verbose-message (&rest args)
  "Display a verbose message with the same ARGS arguments as `message'."
  (declare (indent 0) (debug t))
  `(when proxymacs-verbose
     (proxymacs--message ,@args)))

(defun proxymacs--get-userpass (user password)
  "Return USER:PASSWORD when USER and PASSWORD are non-nil."
  (when (and user password)
    (format "%s:%s" user password)))

(defun proxymacs--build-auth-entry (host realm user-pass)
  "Build a basic auth storage entry for HOST, REALM, and USER-PASS."
  (list host
        (cons (or realm "")
              (base64-encode-string user-pass t))))

(defun proxymacs--enable-http ()
  "Configure Emacs `url' HTTP and HTTPS proxy settings."
  (unless (or proxymacs-http-host proxymacs-https-host)
    (user-error "[proxymacs] `proxymacs-http-host' or `proxymacs-https-host' must be set"))
  (let* ((http-proxy-host-port (when proxymacs-http-host
                                 (if proxymacs-http-port
                                     (format "%s:%s" proxymacs-http-host proxymacs-http-port)
                                   proxymacs-http-host)))
         (https-host (or proxymacs-https-host proxymacs-http-host))
         (https-port (or proxymacs-https-port proxymacs-http-port))
         (https-proxy-host-port (when https-host
                                  (if https-port
                                      (format "%s:%s" https-host https-port)
                                    https-host)))
         (no-proxy (cond ((stringp proxymacs-http-no-proxy)
                          proxymacs-http-no-proxy)
                         ((and proxymacs-http-no-proxy
                               (listp proxymacs-http-no-proxy))
                          (mapconcat #'identity proxymacs-http-no-proxy "\\|"))))
         (https-realm (or proxymacs-https-realm proxymacs-http-realm))
         (http-user-pass (proxymacs--get-userpass
                          proxymacs-http-user proxymacs-http-password))
         (https-user-pass (proxymacs--get-userpass
                           (or proxymacs-https-user proxymacs-http-user)
                           (or proxymacs-https-password
                               proxymacs-http-password)))
         services
         auth-storage)
    (when http-proxy-host-port
      (push (cons "http" http-proxy-host-port) services))
    (when https-proxy-host-port
      (push (cons "https" https-proxy-host-port) services))
    (when (and services no-proxy)
      (push (cons "no_proxy" no-proxy) services))
    (setq url-proxy-services (nreverse services))

    (when (and http-proxy-host-port http-user-pass)
      (push (proxymacs--build-auth-entry
             http-proxy-host-port proxymacs-http-realm http-user-pass)
            auth-storage))
    (when (and https-proxy-host-port https-user-pass
               (or (not (equal https-proxy-host-port http-proxy-host-port))
                   (not http-user-pass)))
      (push (proxymacs--build-auth-entry
             https-proxy-host-port https-realm https-user-pass)
            auth-storage))
    (setq url-http-proxy-basic-auth-storage (nreverse auth-storage))))

(defun proxymacs--disable-http ()
  "Restore Emacs `url' HTTP and HTTPS proxy settings to default values."
  (setq url-proxy-services nil)
  (setq url-http-proxy-basic-auth-storage nil))

(defun proxymacs--enable-socks ()
  "Configure Emacs `url' and `socks' proxy settings."
  (unless (and proxymacs-socks-host proxymacs-socks-port)
    (user-error "[proxymacs] `proxymacs-socks-host' and `proxymacs-socks-port' must be set"))
  (let ((version (or proxymacs-socks-version 5))
        (port (if (stringp proxymacs-socks-port)
                  (string-to-number proxymacs-socks-port)
                proxymacs-socks-port)))
    (setq socks-server (list "Default server"
                             proxymacs-socks-host
                             port
                             version))
    (setq socks-noproxy
          (cond ((stringp proxymacs-socks-no-proxy)
                 (list proxymacs-socks-no-proxy))
                ((listp proxymacs-socks-no-proxy)
                 proxymacs-socks-no-proxy)))
    (setq socks-username (or proxymacs-socks-user (user-login-name)))
    (setq socks-password proxymacs-socks-password)
    (setq url-gateway-method 'socks)))

(defun proxymacs--disable-socks ()
  "Restore Emacs `url' and `socks' proxy settings to default values."
  (setq url-gateway-method 'native)
  (setq socks-server (list "Default server" nil 1080 5))
  (setq socks-noproxy '("localhost"))
  (setq socks-username (user-login-name))
  (setq socks-password nil))

(defun proxymacs--enable ()
  "Configure proxies based on `proxymacs-proxy-type'."
  (pcase proxymacs-proxy-type
    ('nil
     (user-error "[proxymacs] No proxy type configured. Set `proxymacs-proxy-type' to `http' or `socks'"))
    ('http
     (proxymacs--disable-socks)
     (proxymacs--enable-http)
     (proxymacs--verbose-message "Proxy configuration enabled."))
    ('socks
     (proxymacs--disable-http)
     (proxymacs--enable-socks)
     (proxymacs--verbose-message "Proxy configuration enabled."))
    (_
     (user-error "[proxymacs] Invalid `proxymacs-proxy-type': %S (expected `http' or `socks')"
                 proxymacs-proxy-type))))

(defun proxymacs--disable ()
  "Disable HTTP, HTTPS, and SOCKS proxies."
  (proxymacs--disable-http)
  (proxymacs--disable-socks)
  (proxymacs--verbose-message "Proxy configuration disabled."))

;;;###autoload
(define-minor-mode proxymacs-mode
  "Toggle `proxymacs-mode'."
  :global t
  :lighter " ProxyM"
  :group 'proxymacs
  (if proxymacs-mode
      (condition-case err
          (proxymacs--enable)
        (error
         (setq proxymacs-mode nil)
         (signal (car err) (cdr err))))
    (proxymacs--disable)))

(provide 'proxymacs)
;;; proxymacs.el ends here
