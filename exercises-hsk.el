(require 'exercises)

(defvar exercises-hsk-directory "~/my/git-repos/exercises-hsk")

(cl-defun exercises-hsk-build-deck-name-from-file-and-outline (&key filename outline)
  (exercises-build-deck-name-from-file-and-outline
   :dir exercises-hsk-directory
   :filename filename
   :outline outline))

(cl-defun exercises-hsk-dialogue-with-single-question (&key
                                                       filename-source
                                                       outline
                                                       filename-export
                                                       notetype)
  (let ((data (exercises-get-subtree-at-point-as-alist)))
    (with-current-buffer (find-file-noselect filename-export)
      (cl-loop
       for item in (cdr data)
       do (insert
           (string-join
            (flatten-tree
             (list
              (exercises-hsk-build-deck-name-from-file-and-outline
               :filename filename-source
               :outline outline)
              notetype
              (alist-get "id" item nil nil 'equal)
              (car item)
              (replace-regexp-in-string
               "\n"
               "<br>"
               (alist-get "对话" item nil nil 'equal))
              (alist-get "问题" item nil nil 'equal)
              ;; The alternatives are capital letters because in the
              ;; "HSK Standard Course", the alternatives of listening
              ;; exercises are shown that way.
              (cl-loop for letter in '("A" "B" "C" "D")
                       collect (alist-get
                                letter
                                (alist-get "选择" item nil nil 'equal)
                                nil
                                nil
                                'equal))
              (alist-get "答案" item nil nil 'equal)))
            "	")
           "\n")))))

(provide 'exercises-hsk)
