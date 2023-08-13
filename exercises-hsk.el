(require 'exercises)

(defvar exercises-hsk-directory "~/my/git-repos/exercises-hsk")

(cl-defun exercises-hsk-build-deck-name-from-file-and-outline (&key filename outline)
  (exercises-build-deck-name-from-file-and-outline
   :dir exercises-hsk-directory
   :filename filename
   :outline outline))

(provide 'exercises-hsk)
