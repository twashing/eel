;;; eel.el --- Yet another ChatGPT client for Emacs  -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Timothy Washington twashing@gmail.com

;; Author: Timothy Washington twashing@gmail.com
;; Maintainer: Timothy Washington twashing@gmail.com
;; Created: 2023
;; Version: 0.0.0
;; Package-Requires: ((emacs "26.3") (plz "0.3"))
;; Homepage: https://github.com/twashing/eel

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; DOCS HERE

;;; Code:

(use-package! plz)


(setq eel-api-key "")

(defun eel/select-region ()
  (interactive)
  (buffer-substring-no-properties (region-beginning) (region-end)))

(defun eel/select-line ()
  (interactive)
  (buffer-substring-no-properties (line-beginning-position) (line-ending-position)))


(defun eel/send-to-openai (message)

  (plz 'post "https://api.openai.com/v1/chat/completions"
    :headers
    `(("Authorization" . ,(concat "Bearer " eel-api-key))
      ("Content-Type" . "application/json"))
    :body (json-encode `(("model" . "gpt-3.5-turbo")
                         ("messages" . [(("role" . "user") ("content" . ,message))])))
    :as #'json-read))

(defun eel/display-response (message)

  (let ((beg (region-beginning))
        (end (region-end)))

    ;; Select the region and insert text below it
    (save-excursion
      (goto-char end)
      (newline)
      (insert message)
      (pulse-momentary-highlight-one-line))))

(defun eel/send ()
  (interactive)

  (let* ((message (if (region-active-p)
                      (eel/select-region)
                    (eel/select-line)))
         (response (eel/send-to-openai message))
         (response-trimmed (map-nested-elt response '(choices 0 message content))))

    (message "%s" response-trimmed)
    (eel/display-response response-trimmed)))

(defvar eel-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c RET") #'eel/send)
    map)
  "Some doc string.")

(define-minor-mode eel-mode
  "This is a doc string."
  :global nil
  :keymap eel-map)

;; (define-package "eel" "0.0.1"
;;   "Yet another ChatGPT client for Emacs"
;;   :authors '(("Timothy Washington" . "twashing@gmail.com"))
;;   :url "https://github.com/twashing/eel"
;;   :depends (plz "0.5.4"))


(provide 'eel)


;; This is how we register an Elisp file as a package that we can
;; load.
;; (add-to-list 'load-path "path/to/directory/of/eel")

;; (require 'eel) ;; OR (use-package eel)
