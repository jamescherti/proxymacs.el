;;; proxy-config.el --- An Emacs Lisp package that simplifies HTTP and HTTPS proxy configuration with optional authentication and automatic subprocess integration. -*- lexical-binding: t; -*-

;; Copyright (C) 2026 James Cherti

;; Author: James Cherti <https://www.jamescherti.com/contact/>
;; Version: 0.9.9
;; URL: https://github.com/jamescherti/proxy-config.el
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

(defgroup proxy-config nil
  "An Emacs Lisp package that simplifies HTTP and HTTPS proxy configuration with optional authentication and automatic subprocess integration."
  :group 'proxy-config
  :prefix "proxy-config-"
  :link '(url-link
          :tag "Github"
          "https://github.com/jamescherti/proxy-config.el"))

(defcustom proxy-config-verbose nil
  "Enable displaying verbose messages."
  :type 'boolean
  :group 'proxy-config)

(defun proxy-config--message (&rest args)
  "Display a message with the same ARGS arguments as `message'."
  (apply #'message (concat "[proxy-config] " (car args)) (cdr args)))

(defmacro proxy-config--verbose-message (&rest args)
  "Display a verbose message with the same ARGS arguments as `message'."
  (declare (indent 0) (debug t))
  `(progn
     (when proxy-config-verbose
       (proxy-config--message
        (concat ,(car args)) ,@(cdr args)))))

;;;###autoload
(define-minor-mode proxy-config-mode
  "Toggle `proxy-config-mode'."
  :global t
  :lighter " proxy-config"
  :group 'proxy-config
  (if proxy-config-mode
      t
    t))

(provide 'proxy-config)
;;; proxy-config.el ends here
