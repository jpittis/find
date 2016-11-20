(use posix)
(use files)
(use irregex)

(define (exit-with-usage)
  (printf "usage: find <directory>\n")
  (exit 1))

(define (directory-from-arguments)
  (if (< (length (command-line-arguments)) 1)
    (exit-with-usage)
    (let ((dir (car (command-line-arguments))))
      (if (directory? dir) dir (exit-with-usage)))))

(define (regexp-from-arguments)
  (if (< (length (command-line-arguments)) 2)
    #f
    (irregex (car (cdr (command-line-arguments))))))

(define (loop-over-files dir found)
  (for-each (lambda (d)
              (let ((path (make-pathname dir d)))
                (if (directory? path)
                  (loop-over-files path found)
                  (found path))))
            (directory dir)))

(define regex (regexp-from-arguments))

(loop-over-files (directory-from-arguments)
                 (lambda (path)
                   (if (or (not regex) (irregex-search regex path))
                     (printf "~A\n" path))))
