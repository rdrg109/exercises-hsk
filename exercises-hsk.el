(require 'exercises)

(defvar exercises-hsk-directory "~/my/git-repos/exercises-hsk")

(cl-defun exercises-hsk-5-textbook-exercises-part-1-export (&key filename-input filename-output)
  (let* ((outline '("练习" "1"))
         (deck
          (exercises-hsk-build-deck-name-from-file-and-outline
           filename-input outline))
         (notetype "e5cbd9a2-e6f3-4b45-9420-bbf89dcd834d")
         (data (exercises-get-subtree-as-alist
                :filename filename-input
                :outline outline))
         (alternatives (alist-get "选择" data nil nil 'equal))
         (exercises (alist-get "题目" data nil nil 'equal)))
    (with-current-buffer (find-file-noselect filename-output)
      (insert
       (string-join
        (flatten-tree
         (list
          deck
          notetype
          (alist-get "id" data nil nil 'equal)
          (exercises-fill-list-with-empty-strings
           (cl-loop
            for alternative in alternatives
            collect (cdr alternative))
           ;; The function
           ;; `hsk-5-textbook-exercises-part-1-get-max-number-of-alternatives'
           ;; was used to find out the maximum number of alternatives
           ;; in this type of exercise.
           8)
          (cl-loop for exercise in exercises
                   collect (list
                            (alist-get "句子填空" (cdr exercise) nil nil 'equal)
                            (alist-get "答案" (cdr exercise) nil nil 'equal)))))
        "	")
       "\n"))))


(cl-defun exercises-hsk-5-textbook-exercises-part-1-get-max-number-of-alternatives ()
  (exercises-unique-max-headlines
   :files (directory-files-recursively
           (concat
            (file-name-as-directory
             exercises-hsk-directory)
            "第五级")
           "\\`课本\\.org\\'")
   :outline '("练习" "1" "选择")
   :testfn '<))

(cl-defun exercises-hsk-5-textbook-exercises-part-2-export (&key filename-input filename-output)
  (with-current-buffer (find-file-noselect filename-output)
    (let* ((outline '("练习" "2"))
           (deck
            (exercises-hsk-build-deck-name-from-file-and-outline
             filename-input outline))
           (notetype "4d1324a6-7ce2-4290-a7f7-7449d6739058")
           (data (exercises-get-subtree-as-alist
                  :filename filename-input
                  :outline outline))
           (exercises (cdr data)))
      (insert
       (string-join
        (cl-loop
         for exercise in exercises
         collect
         (string-join
          (list
           deck
           notetype
           (alist-get "id" exercise nil nil 'equal)
           (alist-get "句子填空" (cdr exercise) nil nil 'equal)
           (alist-get "A" (alist-get "选择" (cdr exercise) nil nil 'equal) nil nil 'equal)
           (alist-get "B" (alist-get "选择" (cdr exercise) nil nil 'equal) nil nil 'equal)
           (alist-get "答案" (cdr exercise) nil nil 'equal))
          "	"))
        "\n")
       "\n"))))

(cl-defun exercises-hsk-build-deck-name-from-file-and-outline (file outline)
  (concat
   (replace-regexp-in-string
    "/"
    "::"
    (file-relative-name
     (replace-regexp-in-string "\\.org\\'" "" file)
     exercises-hsk-directory))
   "::"
   (string-join outline "::")))


(cl-defun exercises-hsk-4-exam-reading-part-3-export (&key filename-input filename-output)
  (with-current-buffer (find-file-noselect filename-output)
    (let* ((outline '("阅读" "第三部分"))
           (deck
            (exercises-hsk-build-deck-name-from-file-and-outline
             filename-input outline))
           (notetype "38a1af04-336c-437d-be8f-2f2f30f3e723")
           (data (exercises-get-subtree-as-alist
                  :filename filename-input
                  :outline outline))
           (exercises (cdr data)))
      (insert
       (string-join
        (cl-loop
         for exercise in exercises
         collect
         (string-join
          (flatten-tree
           (list
            deck
            notetype
            (alist-get "id" exercise nil nil 'equal)
            (car exercise)
            (alist-get "段话" (cdr exercise) nil nil 'equal)
            (alist-get "星星" (cdr exercise) nil nil 'equal)
            (cl-loop
             for alternative in '("A" "B" "C" "D")
             collect (alist-get alternative
                                (alist-get "选择" exercise nil nil 'equal)
                                nil nil 'equal))
            (alist-get "答案" (cdr exercise) nil nil 'equal)))
          "	"))
        "\n")
       "\n"))))
