(import hyde
        srfi-1
        srfi-13
        (chicken io)
        (chicken irregex)
        (chicken time)
        (chicken time posix)
        (html-parser))

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

;; Generate social media icons
(define (make-media-icon icon-title icon-image icon-url)
  `(a (@ (href ,icon-url))
     (img (@ (src ,icon-image)
             (alt ,icon-title)
             (width "30")
             (class "rounded ml-1 mr-1")))))

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

  (define (make-bio-button lang lang-short)
    `(button (@ (class "btn btn-sm btn-outline-secondary mr-1")
                (type "button")
                (onclick ,(string-append "setBio('" lang-short "');")))
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

  (define now (current-seconds))

  (define (make-event time event)
    `(tr (@ (class "event-row"))
       (td (@ (class "text-nowrap")) ,time)
       (td                           ,event)))


  `(table (@ (id "events-table") (class "table table-bordered table-hover"))
    (thead
      (tr
        (th (@ (class "text-nowrap") (data-field "date")) "Date")
        (th (@                       (data-field "desc")) "Event")))
    (tbody
      ,(call-with-input-file
         "data/events.scm"
         (lambda (channel)
           (map (lambda (p) (make-event (car p) (cdr p))) (read channel)))))))
