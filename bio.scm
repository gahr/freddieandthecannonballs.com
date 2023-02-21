(module (fatc bio) (make)

  (import
    (scheme)
    (only (chicken format) sprintf)
    (only (chicken io) read-string)
    (only (spiffy) root-path)
    (prefix (fatc markup) fatc:markup:))

  (define (make lang)
    (with-input-from-file
      (sprintf "~A/data/bio-~A.txt" (root-path) lang)
      (lambda () (fatc:markup:render (read-string)))))
)

