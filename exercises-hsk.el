(require 'exercises)

(defcustom exercises-hsk-directory "~/my/git-repos/exercises-hsk"
  "")

(defcustom exercises-hsk-export-functions
  '(("dialogue-with-5-questions" . exercises-hsk-dialogue-with-multiple-questions))
  "")

(cl-defun exercises-hsk-build-deck-name-from-file-and-outline (&key filename outline)
  (exercises-build-deck-name-from-file-and-outline
   :dir exercises-hsk-directory
   :filename filename
   :outline outline))

(cl-defun exercises-hsk-export-notes (&key files filename-export)
  (exercises-org-export-notes
   :export-functions exercises-hsk-export-functions
   :files files
   :filename-export filename-export))

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

(cl-defun exercises-hsk-dialogue-with-multiple-questions (&key
                                                          filename-source
                                                          outline
                                                          filename-export
                                                          notetype)
  (let ((data (exercises-get-subtree-at-point-as-alist)))
    (with-current-buffer (find-file-noselect filename-export)
      (insert
       (string-join
        (flatten-tree
         (list
          (exercises-hsk-build-deck-name-from-file-and-outline
           :filename filename-source
           :outline outline)
          notetype
          (alist-get "id" (cdr data) nil nil 'equal)
          (replace-regexp-in-string
           "\n"
           "<br>"
           (alist-get "对话" (cdr data) nil nil 'equal))
          (alist-get "音频" (cdr data) nil nil 'equal)
          (cl-loop
           for question in (alist-get "题目" (cdr data) nil nil 'equal)
           collect (list
                    (alist-get "id" question nil nil 'equal)
                    (car question)
                    (alist-get "问题" question nil nil 'equal)
                    (alist-get "音频" question nil nil 'equal)
                    (cl-loop
                     for alternative in (alist-get "选择" question nil nil 'equal)
                     collect (cons (car alternative) (cdr alternative)))
                    (alist-get "答案" question nil nil 'equal)))))
        "	")
       "\n"))))

(provide 'exercises-hsk)
