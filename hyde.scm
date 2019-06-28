(import hyde
        srfi-1
        srfi-13
        (chicken io)
        (chicken irregex)
        html-parser
        matchable)

;; Exclude vim temporary files
(excluded-paths `(,(irregex '(seq (or "/" bos) "." (* any) ".swp" eos))))

;; Generate fav-icon <rel> tags
;; Each argument is a list where the car is the rel attribute and the cdr is a
;; list of widths.
(define (make-fav-icons . icon-specs)
  (define (gen-one icon-rel icon-width)
    (letrec* ((w         (number->string icon-width))
              (icon-size (string-append w "x" w)))
      `(link (@ (rel   ,icon-rel)
                (sizes ,icon-size)
                (href  ,(string-append "favicons/"
                                       icon-rel "-" icon-size ".png"))
                (type  "image/png")))))

  (map
    (lambda (entry)
      (map
        (lambda (icon-width)
          (gen-one (car entry) icon-width))
        (cdr entry)))
    icon-specs))

;; Generate a set of social media icons. Specs is a list of pairs where the
;; car is the name and the cdr is the url.
(define (make-media-icons specs)
  (map
    (match-lambda
      ((name . url)
        `(a (@ (href ,url))
            (img (@ (src ,(string-append "icons/" (string-downcase name) ".png"))
                    (alt ,name)
                    (width "30")
                    (class "rounded ml-2 mr-2"))))))
    specs))

;; Generate the biography section
(define (make-bio)
  (define bio-languages '("English" "Italiano"))
  
  (define (make-bio-content)
    ;; Element that displays the actual content
    `(p (@ (id "bio-content") (class "text-justify"))))

  (define (make-bio-holder lang content)
    `(span (@ (id ,(string-append "bio-content-" lang))
              (class "d-none"))
           ,content))

  (define (make-bio-button lang short)
    `(button (@ (class "btn btn-sm btn-outline-secondary mr-1")
                (type "button")
                (onclick ,(string-append "setBio('" short "');")))
             ,lang))

  (list
    (make-bio-content)
    (map
      (lambda (lang)
        (letrec* ((short (string-downcase lang 0 2))
                  (file  (string-append "data/bio-" short ".html"))
                  (text  (cdr (call-with-input-file
                                file
                                (lambda (x) (html->sxml x))))))

          (list (make-bio-holder short text)
                (make-bio-button lang short))))

      bio-languages)))

;; Generate the dates table
(define (make-events-table)
  `(table (@ (id "events-table") (class "table table-hover"))
    (tbody
      ,(call-with-input-file
         "data/events.scm"
         (lambda (channel)
           (map (match-lambda
                  ((time . event)
                   `(tr (@ (class "event-row"))
                        (td (@ (class "text-nowrap text-right"))
                            ,time)
                        (td ,event))))
                (read channel)))))))

;; Make a hidden section header to comply with
;; https://www.w3.org/wiki/HTML/Usage/Headings/Missing#section_element_advice
(define (make-hidden-header title)
  `(h3 (@ (class "d-none")) ,title))
