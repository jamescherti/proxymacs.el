;;; proxymacs.el --- An Emacs Lisp package that simplifies HTTP and HTTPS proxy configuration with optional authentication and automatic subprocess integration. -*- lexical-binding: t; -*-

;; Copyright (C) 2026 James Cherti

;; Author: James Cherti <https://www.jamescherti.com/contact/>
;; Version: 0.9.9
;; URL: https://github.com/jamescherti/proxymacs.el
;; Keywords: convenience
;; Package-Requires: ((emacs "24.1"))
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
;; An Emacs Lisp package that simplifies HTTP and HTTPS proxy configuration with optional authentication and automatic subprocess integration..

;;; Code:

(defgroup proxymacs nil
  "Simplify proxy configuration."
  :group 'proxymacs
  :prefix "proxymacs-"
  :link '(url-link
          :tag "Github"
          "https://github.com/jamescherti/proxymacs.el"))

(defcustom proxymacs-verbose nil
  "Enable displaying verbose messages."
  :type 'boolean
  :group 'proxymacs)

(defun proxymacs--message (&rest args)
  "Display a message with the same ARGS arguments as `message'."
  (apply #'message (concat "[proxymacs] " (car args)) (cdr args)))

(defmacro proxymacs--verbose-message (&rest args)
  "Display a verbose message with the same ARGS arguments as `message'."
  (declare (indent 0) (debug t))
  `(progn
     (when proxymacs-verbose
       (proxymacs--message
        (concat ,(car args)) ,@(cdr args)))))

(defvar proxymacs-http-host nil
  "Proxy server address in HOST:PORT format.")

(defvar proxymacs-http-realm nil
  "Authentication realm used by the HTTP proxy.")

(defvar proxymacs-http-user nil
  "Username for proxy authentication, or nil.")

(defvar proxymacs-http-password nil
  "Password for proxy authentication, or nil.")

(defvar proxymacs-http-noproxy nil
  "Regexp matching hosts that bypass the Emacs URL proxy.")

(defvar proxymacs-http-noproxy-env nil
  "Comma-separated hosts that bypass the proxy in subprocesses.")

(defun proxymacs--get-userpass ()
  "Return proxy credentials as USER:PASSWORD, or nil."
  (when (and proxymacs-http-user
             proxymacs-http-password)
    (format "%s:%s" proxymacs-http-user proxymacs-http-password)))

(defun proxymacs--enable ()
  "Configure HTTP proxies and subprocess proxy integration."
  (interactive)
  (let ((user-pass (proxymacs--get-userpass)))
    (with-no-warnings
      (setq url-proxy-services
            (append
             (list (cons "http" proxymacs-http-host)
                   (cons "https" proxymacs-http-host))
             (when proxymacs-http-noproxy
               (list (cons "no_proxy" proxymacs-http-noproxy)))))

      (setq url-http-proxy-basic-auth-storage
            (when user-pass
              (list (list proxymacs-http-host
                          (cons proxymacs-http-realm
                                (base64-encode-string user-pass t)))))))))

;;;###autoload
(define-minor-mode proxymacs-mode
  "Toggle `proxymacs-mode'."
  :global t
  :lighter " ProxyM"
  :group 'proxymacs
  (if proxymacs-mode
      (proxymacs--enable)
    ;; HTTP
    (with-no-warnings
      (setq url-proxy-services nil)
      (setq url-http-proxy-basic-auth-storage nil))))

(provide 'proxymacs)
;;; proxymacs.el ends here
