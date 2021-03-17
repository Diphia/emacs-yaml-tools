(defun fetch-yaml-indentation-level (s)
  (cond ((or (string-match "^ " s) (string-match "^-" s))
         (+ 1 (fetch-yaml-indentation-level (substring s 1))))
        (t 0)))

(defun fetch-current-line ()
  (buffer-substring-no-properties (point-at-bol) (point-at-eol)))

(defun yaml-not-blank (s)
  (string-match "[^[:blank:]]" s))

(defun yaml-not-comment (s)
  (not (string-match "^\s*#" s)))

(defun yaml-inside-array (s)
  (and (string-match "^\s*-.*" s) (yaml-not-comment s)))

(defun yaml-not-execute (s)
  (not (string-match "^\s*\t*{{.*}}" s)))

(defun format-yaml-line (s)
  (let* ((s (replace-regexp-in-string "^[ -:]*" "" s))
         (s (replace-regexp-in-string ":$" "" s)))
    s))

(defun extract-yaml-key (s)
  (car (split-string s ":")))

(defun strip-string (s)
  (replace-regexp-in-string "\s*\t*$" "" (replace-regexp-in-string "^\s\t*" "" s)))

(defun extract-yaml-value (s)
  (let ((current-level (fetch-yaml-indentation-level s)))
    (if (not (string-equal "" (car (cdr (split-string s ":"))))) (car (cdr (split-string s ":")))
          (progn
           (beginning-of-line 2)
           (let* ((new-line (fetch-current-line))
                  (new-level (fetch-yaml-indentation-level new-line)))
             (if (= new-level (+ current-level 4))
                 (strip-string new-line) ""))))))

(defun yaml-path-to-list (path)
  (split-string path "\\."))

(load! "eyt-get-path.el")
(load! "eyt-get-value.el")
(load! "eyt-convert-to-ut.el")
