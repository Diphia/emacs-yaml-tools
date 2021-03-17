;;; ../dotfiles/.doom.d/emacs-yaml-tools/eyt-get-path.el -*- lexical-binding: t; -*-

(defun form-path-with-arrow (result)
  (concat (mapconcat 'identity result " => ")
          " => " (extract-yaml-key (format-yaml-line (fetch-current-line)))))

(defun form-path-with-dot (result)
  (concat (mapconcat 'identity result ".")
          "." (extract-yaml-key (format-yaml-line (fetch-current-line)))))

(defun fetch-yaml-path ()
  (save-excursion
    (let ((level (fetch-yaml-indentation-level (fetch-current-line)))
          (index -1)
          result)
      (if (yaml-inside-array (fetch-current-line)) (setq index (+ index 1)))
      (while (> (point) (point-min))
        (beginning-of-line 0)
        (setq line (fetch-current-line))
        (let ((new-level (fetch-yaml-indentation-level line)))
          (cond ((and (= new-level level)
                      (yaml-inside-array line)) (setq index (+ 1 index))))
          (cond ((and (< new-level level)
                      (yaml-not-blank line)
                      (yaml-not-comment line)
                      (yaml-not-execute line))
                 (save-excursion
                   (setq level new-level)
                   (cond ((= index -1)
                          (setq index_attach ""))
                         (t
                          (setq index_attach (concat "[" (number-to-string index) "]"))
                          (setq index -1)))
                   (setq result (push (concat (format-yaml-line line) index_attach) result)))))))
      result)))

(defun eyt-get-path ()
  (interactive)
  (let ((result (fetch-yaml-path)))
    (message (form-path-with-arrow result))
    (kill-new (form-path-with-dot result))))
