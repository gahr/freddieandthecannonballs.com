(module site (run)
  (import
    (scheme)
    (only (chicken base) cut error unless)
    (only (chicken format) sprintf)
    (only (regex) string-match)
    (awful)
    (doctype)
    (prefix (spiffy) sp:)
    (only (srfi-1) find)
    (only (srfi-13) string-titlecase)
    (only (srfi-18) thread-start! thread-sleep!)

    (prefix (page main)   fatc:page:main:)
    (prefix (fatc i18n)   fatc:i18n:)
    (prefix (fatc data)   fatc:data:))

  ;;
  ;; Parameters
  ;;
  (ajax-library "https://code.jquery.com/jquery-3.7.1.min.js")
  (web-repl-access-control (lambda () #t))

  ;;
  ;; Control which static files we aren't going to allow
  ;;
  (let ((block-list '(".*\\.txt$")))
    (sp:handle-file
      (let ((old-handler (sp:handle-file)))
        (lambda (path)
          (if (find (lambda (rex) (string-match rex path)) block-list)
            ((sp:handle-not-found) path)
            (old-handler path))
          ))))

  (define site-title "Freddie & the Cannonballs")

  ;;
  ;; Content
  ;;
  (define (make-ajax)
    (map (lambda (lang)
           (ajax
             "/get-i18n"
             (sprintf "#lang-~A" lang)
             'click
             (lambda () (fatc:i18n:get ($ 'lang #f)))
             arguments: `(("lang" . ,(sprintf "'~A'" lang)))
             update-targets: #t
             success: (sprintf "document.documentElement.lang = '~A';" lang)))
         (map car fatc:i18n:languages))
    (add-javascript
      (sprintf
        "$(document).ready(function() { $('#lang-~A').click(); });"
        (fatc:i18n:default-language))))

  (define (logo)
    `(a
       (@ (href "/"))
       (img
         (@ (class "img-fluid")
            (src   "img/logo-sba2024.jpg")
            (alt   ,site-title)))))

  (define (media-icons)
    (map (lambda (elem)
           (let ((name (car elem))
                 (url  (cdr elem)))
             `(a
                (@ (href ,url))
                (img
                  (@ (class "rounded ml-1 mr-1 icon")
                     (src   ,(sprintf "icons/~A.png" name))
                     (alt   ,(string-titlecase name)))))))

         '(("facebook"  "https://facebook.com/FreddieCannonballs")
           ("instagram" "https://instagram.com/freddieandthecannonballs")
           ("youtube"   "https://www.youtube.com/channel/UCo2lWw8G9p1WiJUHsV8FeUA")
           ("spotify"   "https://open.spotify.com/artist/6vzZRD8QvBc5tOX7c4D1bv")
           ("email"     "mailto:info@freddieandthecannonballs.com"))))

  (define (language-buttons)
    (map (lambda (lang)
           (let ((short (car lang))
                 (long  (cdr lang)))
             `(button
                (@ (class "btn btn-sm btn-outline-secondary mr-1")
                   (type  "button")
                   (id    ,(sprintf "lang-~A" short)))
                ,long)))
         fatc:i18n:languages))

  ;;
  ;; Common stuff
  ;;
  (define (head)
    `(
      (meta (@ (charset      "utf-8")))
      (meta (@ (name         "viewport")
               (content      "width=device-width, initial-scale=1")))
      (meta (@ (name         "description")
               (content      ,site-title)))
      (meta (@ (name         "keywords")
               (content      "Freddie,Federico Albertoni,Cannonballs,Blues")))
      (link (@ (rel          "stylesheet")
               (href         "https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css")
               (integrity    "sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh")
               (crossorigin  "anonymous")))
      ,(map (lambda (size)
              `(link (@ (rel   "apple-touch-icon")
                        (sizes ,(sprintf "~Ax~A" size size))
                        (href  ,(sprintf "favicons/apple-touch-icon-~Ax~A.png" size size))
                        (type  "image/png"))))
            '(57 60 72 76 114 120 144 152 180 192))
      ,(map (lambda (size)
              `(link (@ (rel  "icon")
                        (href ,(sprintf "favicons/icon-~Ax~A.png" size size))
                        (type "image/png"))))
            '(16 32 96))))

  (define (common-pre)
    (make-ajax)
    `((header
        (@ (class "row mt-4"))
        (div
          (@ (class "col text-center"))
          ,(logo)))
      (div
        (@ (class "row mt-4"))
        (nav
          (@ (class "col text-center"))
          ,(media-icons)))
      (div
        (@ (class "row mt-3 justify-content-center"))
        ,(language-buttons))
      (hr)))

  (define (common-post)
    (let ((alf     `(a (@ (href "https://www.alfredocreates.com")) "AlfredoCreates.com"))
          (chicken `(a (@ (href "https://call-cc.org/")) "CHICKEN Scheme"))
          (awful   `(a (@ (href "https://wiki.call-cc.org/egg/awful")) "awful")))
      `(footer
         (@ (class "container"))
         (hr)
         (p
           (@ class "text-center text-muted colophon")
           "Copyright " (literal "&copy;") " 2019-2023 " ,site-title "."
           " Social media icons designed by " ,alf "."
           " Powered by " ,chicken " and " ,awful "."))))

  (define (make-page thunk)
    ;; Backwards-compatible page handling
    (let ((page ($ 'page #f)))
      (if page (redirect-to page)))

    `(
      (div
        (@ (class "container"))
        ,(common-pre)
        ,(thunk)
        ,(common-post))))

  (define (update-data data-url)
    (let loop ()
      (fatc:data:get data-url)
      (thread-sleep! 3600)
      (loop)))

  ;;
  ;; Entry
  ;;
  (define (run args)
    (let ((data-url (member "data-url" args)))
      (unless data-url (error "Required arg: data-rul"))
      (thread-start! (cut update-data (cadr data-url))))

    (map (lambda (elem)
           (define-page (car elem)
                        (lambda () (make-page (cdr elem)))
                        doctype: doctype-html
                        headers: (head)
                        css: "style.css"
                        no-page-javascript: #f
                        use-ajax: #t
                        use-sxml: #t
                        title: site-title))

         `((,fatc:page:main:path . ,fatc:page:main:make))))

)
