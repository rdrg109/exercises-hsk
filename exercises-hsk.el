(require 'exercises)

(exercises-define-group hsk)

(defcustom exercises-hsk-export-functions
  '(("7304a4a2-efe6-4d8e-96dc-e419347c7a56" . exercises-hsk-export-content-with-audio-multiple-choice-exercises)
    ("6e4af68c-3365-49d9-bfcc-70d2ee989ab7" . exercises-hsk-export-summarize-text))
  "")

(cl-defun exercises-hsk-export-content-with-audio-multiple-choice-exercises ()
  (let* ((deck (exercises-anki-build-deck-name-from-file-and-outline
                :dir exercises-hsk-root-dir
                :filename buffer-file-name
                :outline (org-get-outline-path)))
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
                               do (throw 'found (alist-get 'content item-2))))))
         (exercises (exercises-extract-data-multiple-exercises :data data)))
    (with-current-buffer (find-file-noselect exercises-hsk-export-exported-file)
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
                      collect (mapcar 'cdr (remq (assoc 'question-audio exercise) exercise)))))
      (cl-loop
       for exercise in exercises
       do (exercises-anki-insert-note
           :deck deck
           :note-type "text-multiple-choice-exercise"
           :tags '("reading"
                   "single-exercise")
           :fields (list (alist-get 'id exercise)
                         content
                         (mapcar 'cdr (remq (assoc 'question-audio exercise) exercise))))))))

(cl-defun exercises-hsk-export-summarize-text ()
  (let* ((deck (exercises-anki-build-deck-name-from-file-and-outline
                :dir exercises-hsk-root-dir
                :filename buffer-file-name
                :outline (org-get-outline-path)))
         (data (exercises-org-get-subtree-at-point-as-alist))
         (content (replace-regexp-in-string
                   "\n"
                   "<br>"
                   (catch 'found
                     (cl-loop
                      for item in (alist-get 'entries data)
                      when (member (alist-get 'headline item) '("段话"))
                      do (throw 'found (alist-get 'content item))))))
         (content-audio (catch 'found
                          (cl-loop
                           for item in (alist-get 'entries data)
                           when (member (alist-get 'headline item) '("段话"))
                           do (cl-loop
                               for item-2 in (alist-get 'entries item)
                               when (equal (alist-get 'headline item-2) "音频")
                               do (throw 'found (alist-get 'content item-2))))))
         (exercise `((id . ,(alist-get "id" (alist-get 'properties data) nil nil 'equal))
                     (exercise-number . ,(alist-get 'headline data))
                     (alternatives . ,(catch 'value
                                        (cl-loop
                                         for entry in (alist-get 'entries data)
                                         when (equal (alist-get 'headline entry) "选择")
                                         do (throw 'value
                                                   (cl-loop
                                                    for alternative in (alist-get 'entries entry)
                                                    collect (cons (alist-get 'headline alternative)
                                                                  (alist-get 'content alternative)))))))
                     (answer . ,(catch 'found
                                  (cl-loop
                                   for entry in (alist-get 'entries data)
                                   when (equal (alist-get 'headline entry) "答案")
                                   do (throw 'found (alist-get 'content entry))))))))
    (with-current-buffer (find-file-noselect exercises-hsk-export-exported-file)
      (exercises-anki-insert-note
       :deck deck
       :note-type "summarize-text-multiple-choice-exercise"
       :tags '("reading"
               "single-exercise")
       :fields (list (alist-get 'id exercise)
                     (alist-get 'exercise-number exercise)
                     content
                     (alist-get 'alternatives exercise)
                     (alist-get 'answer exercise)))
      (exercises-anki-insert-note
       :deck deck
       :note-type "summarize-audio-multiple-choice-exercise"
       :tags '("listening"
               "single-exercise")
       :fields (list (alist-get 'id exercise)
                     (alist-get 'exercise-number exercise)
                     content
                     content-audio
                     (alist-get 'alternatives exercise)
                     (alist-get 'answer exercise))))))

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
