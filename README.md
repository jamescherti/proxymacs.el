# proxymacs.el - Emacs proxy configuration
![Build Status](https://github.com/jamescherti/proxymacs.el/actions/workflows/melpazoid.yml/badge.svg)
![License](https://img.shields.io/github/license/jamescherti/proxymacs.el)
![](https://jamescherti.com/misc/made-for-gnu-emacs.svg)

- Author: James Cherti <[https://www.jamescherti.com/](https://www.jamescherti.com/)>
- License: GPL

The **[proxymacs](https://github.com/jamescherti/proxymacs.el)** Emacs package simplifies HTTP, HTTPS, and SOCKS proxy configuration.

## Usage

### HTTP and HTTPS Proxy

```elisp
(setq proxymacs-proxy-type 'http) ; 'http is the default
(setq proxymacs-http-host "127.0.0.1")
(setq proxymacs-http-port 3128) ; accepts integer or string
(setq proxymacs-http-no-proxy "^\\(localhost\\|127.0.0.1\\|10\\..*\\|192\\.168\\..*\\)")

;; Optional HTTPS configuration (falls back to HTTP or global host and port when nil):
;; (setq proxymacs-https-host "127.0.0.1")
;; (setq proxymacs-https-port 3128)

;; Optional authentication:
;; (setq proxymacs-http-realm "proxy")
;; (setq proxymacs-http-user "my_user")
;; (setq proxymacs-http-password "my_password")

;; Enable the proxymacs mode
(proxymacs-mode)
```

### SOCKS Proxy

```elisp
(setq proxymacs-proxy-type 'socks)
(setq proxymacs-socks-host "127.0.0.1")
(setq proxymacs-socks-port 1080) ; accepts integer or string
(setq proxymacs-socks-version 5) ; 5 or 4
(setq proxymacs-no-proxy "^\\(localhost\\|127.0.0.1\\|10\\..*\\|192\\.168\\..*\\)")

;; Optional authentication:
;; (setq proxymacs-socks-user "my_user")
;; (setq proxymacs-socks-password "my_password")

;; Enable the proxymacs mode
(proxymacs-mode)
```

## Installation

### Emacs: use-package and straight (Emacs version < 30)

To install *proxymacs* with `straight.el`:

1. If it has not already been done, [add the straight.el bootstrap code](https://github.com/radian-software/straight.el?tab=readme-ov-file#getting-started) to your init file.

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

### General

- `proxymacs-proxy-type`: The active proxy type. Accepts `'http` (for HTTP and HTTPS) or `'socks` (for SOCKS) (default: `nil`).

- `proxymacs-host`: Default proxy server hostname or IP address for HTTP, HTTPS, and SOCKS. Can be overridden by `proxymacs-http-host`, `proxymacs-https-host`, or `proxymacs-socks-host` (default: `nil`).

- `proxymacs-port`: Default proxy server port for HTTP, HTTPS, and SOCKS, integer or string. Can be overridden by `proxymacs-http-port`, `proxymacs-https-port`, or `proxymacs-socks-port` (default: `nil`).

- `proxymacs-no-proxy`: Regexp or list of regexps matching hosts that bypass the proxy. Can be overridden by `proxymacs-http-no-proxy` or `proxymacs-socks-no-proxy` (default: `nil`).


### HTTP

- `proxymacs-http-host`: HTTP proxy server hostname or IP address. When `nil`, `proxymacs-host` is used (default: `nil`).

- `proxymacs-http-port`: HTTP proxy server port, integer or string. When `nil`, `proxymacs-port` (or `8080` if unset) is used (default: `nil`).

- `proxymacs-https-host`: HTTPS proxy server hostname or IP address. When `nil`, `proxymacs-http-host` or `proxymacs-host` is used for HTTPS connections (default: `nil`).

- `proxymacs-https-port`: HTTPS proxy server port, integer or string. When `nil`, `proxymacs-http-port`, `proxymacs-port`, or `8080` is used for HTTPS connections (default: `nil`).

- `proxymacs-http-realm`: Authentication realm used by the HTTP proxy (default: `"Proxy"`).
- `proxymacs-http-user`: Username for proxy authentication (default: `nil`).
- `proxymacs-http-password`: Password for proxy authentication (default: `nil`).
- `proxymacs-https-realm`: Authentication realm used by the HTTPS proxy. When `nil`, `proxymacs-http-realm` is used (default: `nil`).
- `proxymacs-https-user`: Username for HTTPS proxy authentication. When `nil`, `proxymacs-http-user` is used (default: `nil`).
- `proxymacs-https-password`: Password for HTTPS proxy authentication. When `nil`, `proxymacs-http-password` is used (default: `nil`).

- `proxymacs-http-no-proxy`: Regexp or list of regexps matching hosts that bypass the Emacs URL proxy. When `nil`, `proxymacs-no-proxy` is used (default: `nil`).


### SOCKS

- `proxymacs-socks-host`: SOCKS proxy server hostname or IP address. When `nil`, `proxymacs-host` is used (default: `nil`).

- `proxymacs-socks-port`: SOCKS proxy server port, integer or string. When `nil`, `proxymacs-port` (or `1080` if unset) is used (default: `nil`).

- `proxymacs-socks-version`: SOCKS protocol version, `4` or `5` (default: `5`).
- `proxymacs-socks-user`: Username for SOCKS proxy authentication (default: `nil`).
- `proxymacs-socks-password`: Password for SOCKS proxy authentication (default: `nil`).

- `proxymacs-socks-no-proxy`: Regexp or list of regexps matching hosts that bypass the SOCKS proxy. When `nil`, `proxymacs-no-proxy` is used (default: `nil`).


### Other

- `proxymacs-verbose`: Enable displaying verbose messages (default: `nil`).


## Author and License

The *proxymacs* Emacs package has been written by [James Cherti](https://www.jamescherti.com/) and is distributed under terms of the GNU General Public License version 3, or, at your choice, any later version.

Copyright (C) 2026 James Cherti

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

## Links

- [proxymacs.el @GitHub](https://github.com/jamescherti/proxymacs.el)

Other Emacs packages by the same author:

- [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d): This repository hosts a minimal Emacs configuration designed to serve as a foundation for your vanilla Emacs setup and provide a solid base for an enhanced Emacs experience.
- [compile-angel.el](https://github.com/jamescherti/compile-angel.el): **Speed up Emacs!** This package guarantees that all .el files are both byte-compiled and native-compiled, which significantly speeds up Emacs.
- [outline-indent.el](https://github.com/jamescherti/outline-indent.el): An Emacs package that provides a minor mode that enables code folding and outlining based on indentation levels for various indentation-based text files, such as YAML, Python, and other indented text files.
- [vim-tab-bar.el](https://github.com/jamescherti/vim-tab-bar.el): Make the Emacs tab-bar Look Like Vim's Tab Bar.
- [elispcomp](https://github.com/jamescherti/elispcomp): A command line tool that allows compiling Elisp code directly from the terminal or from a shell script. It facilitates the generation of optimized .elc (byte-compiled) and .eln (native-compiled) files.
- [tomorrow-night-deepblue-theme.el](https://github.com/jamescherti/tomorrow-night-deepblue-theme.el): The Tomorrow Night Deepblue Emacs theme is a beautiful deep blue variant of the Tomorrow Night theme, which is renowned for its elegant color palette that is pleasing to the eyes. It features a deep blue background color that creates a calming atmosphere. The theme is also a great choice for those who miss the blue themes that were trendy a few years ago.
- [Ultyas](https://github.com/jamescherti/ultyas/): A command-line tool designed to simplify the process of converting code snippets from UltiSnips to YASnippet format.
- [dir-config.el](https://github.com/jamescherti/dir-config.el): Automatically find and evaluate .dir-config.el Elisp files to configure directory-specific settings.
- [flymake-bashate.el](https://github.com/jamescherti/flymake-bashate.el): A package that provides a Flymake backend for the bashate Bash script style checker.
- [flymake-ansible-lint.el](https://github.com/jamescherti/flymake-ansible-lint.el): An Emacs package that offers a Flymake backend for ansible-lint.
- [inhibit-mouse.el](https://github.com/jamescherti/inhibit-mouse.el): A package that disables mouse input in Emacs, offering a simpler and faster alternative to the disable-mouse package.
- [quick-sdcv.el](https://github.com/jamescherti/quick-sdcv.el): This package enables Emacs to function as an offline dictionary by using the sdcv command-line tool directly within Emacs.
- [enhanced-evil-paredit.el](https://github.com/jamescherti/enhanced-evil-paredit.el): An Emacs package that prevents parenthesis imbalance when using *evil-mode* with *paredit*. It intercepts *evil-mode* commands such as delete, change, and paste, blocking their execution if they would break the parenthetical structure.
- [stripspace.el](https://github.com/jamescherti/stripspace.el): Ensure Emacs Automatically removes trailing whitespace before saving a buffer, with an option to preserve the cursor column.
- [persist-text-scale.el](https://github.com/jamescherti/persist-text-scale.el): Ensure that all adjustments made with text-scale-increase and text-scale-decrease are persisted and restored across sessions.
- [pathaction.el](https://github.com/jamescherti/pathaction.el): Execute the pathaction command-line tool from Emacs. The pathaction command-line tool enables the execution of specific commands on targeted files or directories. Its key advantage lies in its flexibility, allowing users to handle various types of files simply by passing the file or directory as an argument to the pathaction tool. The tool uses a .pathaction.yaml rule-set file to determine which command to execute. Additionally, Jinja2 templating can be employed in the rule-set file to further customize the commands.
- [kirigami.el](https://github.com/jamescherti/kirigami.el): The *kirigami* Emacs package offers a unified interface for opening and closing folds across a diverse set of major and minor modes in Emacs, including `outline-mode`, `outline-minor-mode`, `outline-indent-minor-mode`, `org-mode`, `markdown-mode`, `vdiff-mode`, `vdiff-3way-mode`, `hs-minor-mode`, `hide-ifdef-mode`, `origami-mode`, `yafolding-mode`, `folding-mode`, and `treesit-fold-mode`. With Kirigami, folding key bindings only need to be configured **once**. After that, the same keys work consistently across all supported major and minor modes, providing a unified and predictable folding experience.
- [buffer-guardian.el](https://github.com/jamescherti/buffer-guardian.el): Automatically saves Emacs buffers without requiring manual intervention. By default, it triggers a save when the user switches to another buffer, switches to another window or frame, Emacs loses focus, or the minibuffer is opened. Beyond standard file buffers, *buffer-guardian* also manages specialized editing buffers such as *org-src* and *edit-indirect*. Additional features, disabled by default, include periodic or idle-time saving of all buffers, automatic exclusion of remote, nonexistent, or large files, and support for custom exclusion rules via regular expressions or predicate functions.
