(module (fatc markup) (render)

  (import
    (scheme)
    (only (regex) string-substitute)
    (only (srfi-1) fold))

  (define (render data)
    (fold
      (lambda (elem accum)
        (string-substitute
          (car elem) (cdr elem) accum 'all))
      data
      '(("<([^>]+)>" . "<i>\\1</i>")
        ("{([^}]+)}" . "<b>\\1</b>"))))
)
