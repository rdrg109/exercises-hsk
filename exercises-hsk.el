(require 'exercises)

(exercises-define-group hsk)

(defcustom exercises-hsk-export-functions
  '(("content-with-audio-5-multiple-choice-exercises" . exercises-hsk-export-content-with-audio-multiple-choice-exercises)
    ("content-with-audio-3-multiple-choice-exercises" . exercises-hsk-export-content-with-audio-multiple-choice-exercises)
    ("content-with-audio-4-multiple-choice-exercises" . exercises-hsk-export-content-with-audio-multiple-choice-exercises))
  "")

(cl-defun exercises-hsk-export-content-with-audio-multiple-choice-exercises (&key
                                                                             filename-source
                                                                             outline
                                                                             filename-export
                                                                             notetype)
  (exercises-export-content-with-audio-multiple-choice-exercises
   :filename-source filename-source
   :outline outline
   :filename-export filename-export
   :notetype notetype
   :dir exercises-hsk-root-dir
   :headline-audio "音频"
   :headline-content '("对话" "课文" "段话")
   :headline-exercises "题目"
   :headline-exercise-content "问题"
   :headline-exercise-alternatives "选择"
   :headline-exercise-answer "答案"))

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
