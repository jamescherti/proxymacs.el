# proxymacs.el
![Build Status](https://github.com/jamescherti/proxymacs.el/actions/workflows/melpazoid.yml/badge.svg)
![License](https://img.shields.io/github/license/jamescherti/proxymacs.el)
![](https://jamescherti.com/misc/made-for-gnu-emacs.svg)

- Author: James Cherti <[https://www.jamescherti.com/](https://www.jamescherti.com/)>
- License: GPL

An Emacs package that simplifies HTTP and HTTPS proxy configuration with optional authentication and automatic subprocess integration.

## Usage

```elisp
(setq proxymacs-http-host "127.0.0.1:3128")
(setq proxymacs-http-realm "proxy")
(setq proxymacs-http-no-proxy "^\\(localhost\\|127.0.0.1\\|10\\..*\\|192\\.168\\..*\\)")

;; Optional authentication:
;; (setq proxymacs-http-user "my_user")
;; (setq proxymacs-http-password "my_password")

;; Enable the mode:
(proxymacs-mode)
```

## Installation

### Emacs: use-package and straight (Emacs version < 30)

To install *proxymacs* with `straight.el`:

1. If it hasn't already been done, [add the straight.el bootstrap code](https://github.com/radian-software/straight.el?tab=readme-ov-file#getting-started) to your init file.
2. Add the following code to the Emacs init file:
```emacs-lisp
(use-package proxymacs
  :straight (proxymacs
             :type git
             :host github
             :repo "jamescherti/proxymacs.el"))
```

### Alternative installation: use-package and :vc (Built-in feature in Emacs version >= 30)

To install *proxymacs* with `use-package` and `:vc` (Emacs >= 30):

```emacs-lisp
(use-package proxymacs
  :vc (:url "https://github.com/jamescherti/proxymacs.el"
       :rev :newest))
```

### Alternative installation: Doom Emacs

Here is how to install *proxymacs* on Doom Emacs:

1. Add to the `~/.doom.d/packages.el` file:

```elisp
(package! proxymacs
  :recipe
  (:host github :repo "jamescherti/proxymacs.el"))
```

2. Add to `~/.doom.d/config.el`:

```elisp
(after! proxymacs
  ;; TODO: setq options
  ;; TODO: Load the mode here
  )
```

3. Run the `doom sync` command:

```
doom sync
```

## Customization

* `proxymacs-http-host`: HTTP proxy server address in `HOST:PORT` format (default: `nil`).
* `proxymacs-https-host`: HTTPS proxy server address in `HOST:PORT` format. When `nil`, `proxymacs-http-host` is used for HTTPS connections (default: `nil`).
* `proxymacs-http-realm`: Authentication realm used by the HTTP proxy (default: `"Proxy"`).
* `proxymacs-http-user`: Username for proxy authentication (default: `nil`).
* `proxymacs-http-password`: Password for proxy authentication (default: `nil`).
* `proxymacs-http-no-proxy`: Regexp matching hosts that bypass the Emacs URL proxy (default: `nil`).
* `proxymacs-http-no-proxy-env`: Comma-separated hosts that bypass the proxy in subprocesses (default: `nil`).
* `proxymacs-verbose`: Enable displaying verbose messages (default: `nil`).

## Author and License

The *proxymacs* Emacs package has been written by [James Cherti](https://www.jamescherti.com/) and is distributed under terms of the GNU General Public License version 3, or, at your choice, any later version.

Copyright (C) 2026 James Cherti

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

## Links

- [proxymacs.el @GitHub](https://github.com/jamescherti/proxymacs.el)
