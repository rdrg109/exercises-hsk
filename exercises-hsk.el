(require 'exercises)

(exercises-define-group hsk)

(defcustom exercises-hsk-export-functions
  '(("7304a4a2-efe6-4d8e-96dc-e419347c7a56" . exercises-hsk-export-content-with-audio-multiple-choice-exercises))
  "")

(cl-defun exercises-hsk-export-content-with-audio-multiple-choice-exercises
    (&key filename-source
          outline)
  (let* ((deck (exercises-anki-build-deck-name-from-file-and-outline
                :dir exercises-hsk-root-dir
                :filename filename-source
                :outline outline))
         (data (exercises-org-get-subtree-at-point-as-alist))
         (content (replace-regexp-in-string
                   "\n"
                   "<br>"
                   (catch 'found
                     (cl-loop
                      for item in (alist-get 'entries data)
                      when (member (alist-get 'headline item) '("对话" "课文" "段话"))
                      do (throw 'found (alist-get 'content item))))))
         (content-audio (catch 'found
                          (cl-loop
                           for item in (alist-get 'entries data)
                           when (member (alist-get 'headline item) '("对话" "课文" "段话"))
                           do (cl-loop
                               for item-2 in (alist-get 'entries item)
                               when (equal (alist-get 'headline item-2) "音频")
                               do (throw 'found (alist-get 'content item-2)))))))
    (with-current-buffer (find-file-noselect exercises-hsk-export-exported-file)
      (if (catch 'found
            (cl-loop
             for item in (alist-get 'entries data)
             when (equal (alist-get 'headline item) "题目")
             do (throw 'found (alist-get 'entries item))))
          ;; Multiple exercises
          (let ((exercises (exercises-extract-data-multiple-exercises :data data)))
            (exercises-anki-insert-note
             :deck deck
             :note-type "audio-multiple-choice-exercise"
             :tags '("listening"
                     "multiple-exercises")
             :fields (list (alist-get "id" (alist-get 'properties data) nil nil 'equal)
                           content
                           content-audio
                           (cl-loop
                            for exercise in exercises
                            collect (mapcar 'cdr exercise))))
            (cl-loop
             for exercise in exercises
             do (exercises-anki-insert-note
                 :deck deck
                 :note-type "audio-multiple-choice-exercise"
                 :tags '("listening"
                         "single-exercise")
                 :fields (list (alist-get 'id exercise)
                               content
                               content-audio
                               (mapcar 'cdr exercise))))
            (exercises-anki-insert-note
             :deck deck
             :note-type "text-multiple-choice-exercise"
             :tags '("reading"
                     "multiple-exercises")
             :fields (list (alist-get "id" (alist-get 'properties data) nil nil 'equal)
                           content
                           (cl-loop
                            for exercise in exercises
                            collect (mapcar 'cdr (delq (assoc 'question-audio exercise) exercise)))))
            (cl-loop
             for exercise in exercises
             do (exercises-anki-insert-note
                 :deck deck
                 :note-type "text-multiple-choice-exercise"
                 :tags '("reading"
                         "single-exercise")
                 :fields (list (alist-get 'id exercise)
                               content
                               (mapcar 'cdr (delq (assoc 'question-audio exercise) exercise))))))
        ;; Single exercise
        (let ((exercise (exercises-extract-data-single-exercise :data data)))
          (exercises-anki-insert-note
           :deck deck
           :note-type "text-multiple-choice-exercise"
           :tags '("reading"
                   "single-exercise")
           :fields (list (alist-get 'id exercise)
                         content
                         (mapcar 'cdr (delq (assoc 'question-audio exercise) exercise))))
          (exercises-anki-insert-note
           :deck deck
           :note-type "audio-multiple-choice-exercise"
           :tags '("listening"
                   "single-exercise")
           :fields (list (alist-get 'id exercise)
                         content
                         content-audio
                         (mapcar 'cdr exercise))))))))

(cl-defun exercises-hsk-export-children-content-with-single-question (&key
                                                                      filename-source
                                                                      outline
                                                                      note-type)
  (let ((retrieved-data
         (exercises-export-content-with-audio-single-multiple-choice-exercise
          :data (exercises-get-subtree-at-point-as-alist)
          :headline-content '("段话")
          :headline-content-audio "音频"
          :headline-exercise-alternatives "选择"
          :headline-exercise-answer "答案")))
    (with-current-buffer (find-file-noselect exercises-hsk-export-exported-file)
      (insert
       (string-join
        (list
         (exercises-hsk-build-deck-name-from-file-and-outline
          :filename filename-source
          :outline outline)
         note-type
         retrieved-data)
        "	")
       "\n"))))

(provide 'exercises-hsk)
