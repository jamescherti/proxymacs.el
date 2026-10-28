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
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; An Emacs Lisp package that simplifies HTTP and HTTPS proxy configuration.

;;; Code:

(defgroup proxymacs nil
  "Simplify proxy configuration."
  :group 'proxymacs
  :prefix "proxymacs-"
  :link '(url-link
          :tag "Github"
          "https://github.com/jamescherti/proxymacs.el"))

(defcustom proxymacs-proxy-type 'http
  "The active proxy type."
  :type '(choice (const :tag "HTTP and HTTPS proxy" http)
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
When nil, `proxymacs-http-host' is used for HTTPS connections."
  :type '(choice (const :tag "Use `proxymacs-http-host'" nil) string)
  :group 'proxymacs)

(defcustom proxymacs-https-port nil
  "HTTPS proxy server port.
When nil, `proxymacs-http-port' is used for HTTPS connections."
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

(defcustom proxymacs-http-no-proxy nil
  "Regexp matching hosts that bypass the Emacs URL proxy.

For example:
\"^\\\\(localhost\\\\|127\\\\.0\\\\.0\\\\.1\\\\|192\\\\.168\\\\..*\\\\)\""
  :type '(choice (const :tag "None" nil) regexp)
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
  "SOCKS protocol version (4 or 5)."
  :type '(choice (const :tag "SOCKS5" 5)
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

(defun proxymacs--get-userpass ()
  "Return proxy credentials as USER:PASSWORD, or nil."
  (when (and proxymacs-http-user
             proxymacs-http-password)
    (format "%s:%s" proxymacs-http-user proxymacs-http-password)))

(defun proxymacs--build-auth-entry (host user-pass)
  "Build a basic auth storage entry for HOST using USER-PASS."
  (list host
        (cons (or proxymacs-http-realm "")
              (base64-encode-string user-pass t))))

(defun proxymacs--enable-http ()
  "Configure Emacs `url' HTTP and HTTPS proxy settings."
  (let* ((http-proxy (when proxymacs-http-host
                       (if proxymacs-http-port
                           (format "%s:%s" proxymacs-http-host proxymacs-http-port)
                         proxymacs-http-host)))
         (https-host (or proxymacs-https-host proxymacs-http-host))
         (https-port (or proxymacs-https-port proxymacs-http-port))
         (https-proxy (when https-host
                        (if https-port
                            (format "%s:%s" https-host https-port)
                          https-host)))
         (user-pass (proxymacs--get-userpass))
         services
         auth-storage)
    (when http-proxy
      (push (cons "http" http-proxy) services))
    (when https-proxy
      (push (cons "https" https-proxy) services))
    (when (and services proxymacs-http-no-proxy)
      (push (cons "no_proxy" proxymacs-http-no-proxy) services))
    (setq url-proxy-services (nreverse services))

    (when user-pass
      (when http-proxy
        (push (proxymacs--build-auth-entry http-proxy user-pass) auth-storage))
      (when (and https-proxy (not (equal https-proxy http-proxy)))
        (push (proxymacs--build-auth-entry https-proxy user-pass) auth-storage)))
    (setq url-http-proxy-basic-auth-storage (nreverse auth-storage))))

(defun proxymacs--disable-http ()
  "Restore Emacs `url' HTTP and HTTPS proxy settings to default values."
  (setq url-proxy-services nil)
  (setq url-http-proxy-basic-auth-storage nil))

(defun proxymacs--enable-socks ()
  "Configure Emacs `url' and `socks' proxy settings."
  (when (and proxymacs-socks-host proxymacs-socks-port)
    (require 'socks)
    (let ((version (or proxymacs-socks-version 5))
          (port (if (stringp proxymacs-socks-port)
                    (string-to-number proxymacs-socks-port)
                  proxymacs-socks-port)))
      (setq socks-server (list "Default server"
                               proxymacs-socks-host
                               port
                               version))
      (setq socks-noproxy
            (cond ((null proxymacs-socks-no-proxy) nil)
                  ((stringp proxymacs-socks-no-proxy)
                   (list proxymacs-socks-no-proxy))
                  ((listp proxymacs-socks-no-proxy)
                   proxymacs-socks-no-proxy)))
      (setq socks-username (or proxymacs-socks-user (user-login-name)))
      (setq socks-password proxymacs-socks-password)
      (setq url-gateway-method 'socks))))

(defun proxymacs--disable-socks ()
  "Restore Emacs `url' and `socks' proxy settings to default values."
  (setq url-gateway-method 'native)
  (when (featurep 'socks)
    (setq socks-server (list "Default server" nil 1080 5))
    (setq socks-noproxy '("localhost"))
    (setq socks-username (user-login-name))
    (setq socks-password nil)))

(defun proxymacs--enable ()
  "Configure proxies based on `proxymacs-proxy-type'."
  (pcase proxymacs-proxy-type
    ('http
     (proxymacs--enable-http))
    ('socks
     (proxymacs--enable-socks))
    (_
     (user-error "[proxymacs] Unknown proxy type: %s" proxymacs-proxy-type)))
  (proxymacs--verbose-message "Proxy configuration enabled."))

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
      (proxymacs--enable)
    ;; HTTP
    (proxymacs--disable)))

(provide 'proxymacs)
;;; proxymacs.el ends here
