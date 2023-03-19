(module (fatc i18n) (languages default-language get)

  (import
    (scheme)
    (only (chicken format) sprintf)
    (only (chicken string) string-split)
    (only (chicken sort) sort)
    (only (srfi-1) filter null-list? zip)
    (prefix (spiffy) sp:)
    (prefix (intarweb) iw:)
    (prefix (fatc bio) fatc:bio:))

  (define languages
    '(("en" . "English")
      ("it" . "Italiano")))

  (define (default-language)
    (let* ((hdrs (iw:header-contents 'accept-language (iw:request-headers (sp:current-request))))
           (tags (map iw:get-value hdrs))
           (vals (map (lambda (elem) (car (string-split (symbol->string elem) "-"))) tags))
           (pars (map (lambda (elem) (or (iw:get-param 'q elem) 1.0)) hdrs))
           (both (zip vals pars))
           (cand (filter (lambda (elem) (assoc (car elem) languages)) both))
           (best (if (null-list? cand)
                   (car languages)
                   (caar (sort cand (lambda (lhs rhs) (> (cadr lhs) (cadr rhs))))))))
      best))

  (define language-terms
    ;; The thunk that wraps the inner alist allows us to re-evaluate the values
    ;; at each request, to always fetch a fresh bio.
    `(("en" .
       ,(lambda ()
          `((events   . "Events")
            (download . "Download the full album (CD1)")
            (here     . "here")
            (bio      . (literal ,(fatc:bio:make "en"))))))

      ("it" .
       ,(lambda ()
          `((events   . "Eventi")
            (download . "Scarica l'intero album (CD1)")
            (here     . "qui")
            (bio      . (literal ,(fatc:bio:make "it"))))))))


  (define (get lang)
    (map (lambda (elem) `(,(sprintf "i18n-~A" (car elem)) ,(cdr elem)))
         (let ((terms (assoc (or lang (default-language)) language-terms)))
           (if terms ((cdr terms)) '()))))
)
