;;; sb-rakuten.el --- shimbun backend for rakuten diary -*- coding: iso-2022-7bit; -*-

;; Copyright (C) 2003 NAKAJIMA Mikio <minakaji@namazu.org>

;; Author: NAKAJIMA Mikio <minakaji@namazu.org>
;; Keywords: news
;; Created: Nov 1, 2003

;; This file is a part of shimbun.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 59 Temple Place, Suite 330; Boston, MA 02111-1307, USA.

;;; Commentary:

;;; Code:

(require 'shimbun)
(require 'sb-rss)

(luna-define-class shimbun-rakuten (shimbun-rss) ())

(defcustom shimbun-rakuten-group-alist
  nil ;; '((rakuten-id . email-address))
  "*List of subscribing diaries served by Rakuten."
  :group 'shimbun
  :type '(repeat (cons
		  :format "%v" :indent 2
		  (string :tag "Rakuten ID")
		  (string :tag "Mail address"))))

(defvar shimbun-rakuten-coding-system 'euc-japan)
(defvar shimbun-rakuten-content-start
  ;;"^<img src=\"\/img\/face\/[0-9]\\.gif.+</table>"
  "^</table>\n+<center>")
(defvar shimbun-rakuten-content-end "^<\\/body>")

(luna-define-method shimbun-reply-to ((shimbun shimbun-rakuten))
  (cdr (assoc (shimbun-current-group-internal shimbun)
	      shimbun-rakuten-group-alist)))

(luna-define-method shimbun-groups ((shimbun shimbun-rakuten))
  (mapcar 'car shimbun-rakuten-group-alist))

(luna-define-method shimbun-index-url ((shimbun shimbun-rakuten))
  (format "http://api.plaza.rakuten.ne.jp/%s/rss/"
	  (shimbun-current-group-internal shimbun)))

(luna-define-method shimbun-rss-build-message-id
  ((shimbun shimbun-rakuten) url date)
  (unless (string-match "http://\\([^\/]+\\)/[^\/]+/[^\/]+/\\([0-9]+\\)" url)
    (error "Cannot find a message-id base"))
    (format "%s%%%s@%s"
	    (match-string-no-properties 2 url)
	    (shimbun-current-group-internal shimbun)
	    (match-string-no-properties 1 url)))

(luna-define-method shimbun-rss-get-date
  ((shimbun shimbun-rakuten) url)
  (unless (string-match "http://[^\/]+/[^\/]+/[^\/]+/\\([0-9]+\\)" url)
    (error "Cannot find a date base"))
  (let ((date (match-string-no-properties 1 url)))
    (shimbun-make-date-string
     (string-to-number (substring date 0 4))
     (string-to-number (substring date 4 6))
     (string-to-number (substring date 6 8)))))

(luna-define-method shimbun-rss-process-date
  ((shimbun shimbun-rakuten) date)
  date)

(luna-define-method shimbun-make-contents :before
  ((shimbun shimbun-rakuten) header)
  (save-excursion
    (let ((string
	   (format
	    ">$B46A[$r=q$/(B</a>$B("(B\
<a href=\"http://plaza.rakuten.co.jp/%s/bbs/\">$B7G<(HD$X(B</a>$B("(B"
	    (shimbun-current-group-internal shimbun))))
      (subst-char-in-region (point-min) (point-max) ?\t ?\  t)
      (while (re-search-forward ">$B46A[$r=q$/(B<\\/a>$B("(B" nil t nil)
	  (replace-match string)))))

(provide 'sb-rakuten)

;;; sb-rakuten.el ends here
