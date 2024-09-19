(module page.main (path make)

  (import
    (scheme)
    (only (chicken base) unless)
    (only (chicken format) sprintf)
    (only (awful) main-page-path)
    (only (srfi-1) filter)
    (srfi-19)
    (prefix (fatc gigs) fatc:gigs:))

  (define path (main-page-path))

  (define (make-pics)
    `((div
        (@ (class "row mt-3"))
        (section
          (@ (class "col-md"))
          (h3 (@ (class "d-none")) "Freddie picture")
          (p
            (@ (class "text-justify"))
            (img
              (@ (class "img-fluid img-thumbnail")
                 (src   "img/freddie-2022.jpg")
                 (alt   "Freddie & the Cannonballs"))))
          )
        (section
          (@ (class "col-md"))
          (h3 (@ (class "d-none")) "Band picture")
          (p
            (@ (class "text-justify"))
            (img
              (@ (class "img-fluid img-thumbnail")
                 (src   "img/band-2022.jpg")
                 (alt   "Freddie & the Cannonballs"))))))))

  (define (make-bio)
    `((div
        (@ (class "row"))
        (section
          (@ (class "col-md md-2"))
          (h3 (@ (class "d-none")) "Biography")
          (p
            (@ (class "text-justify")
               (id    "i18n-bio")))))))

  (define (format-gig-dates gig)
    (let ((d1 (fatc:gigs:date1 gig))
          (d2 (fatc:gigs:date2 gig)))
      (if (not d2)
        (date->string d1 "~e ~b ~Y")
        (let ((month1 (date-month d1))
              (year1  (date-year d1))
              (month2 (date-month d2))
              (year2  (date-year d2)))
          (if (eq? year1 year2)
            (if (eq? month1 month2)
              (sprintf "~A - ~A ~A"
                       (date->string d1 "~e")
                       (date->string d2 "~e")
                       (date->string d1 "~b ~Y"))
              (sprintf "~A - ~A"
                       (date->string d1 "~e ~b")
                       (date->string d2 "~e ~b ~Y")))
            (sprintf "~A - ~A"
                     (date->string d1 "~e ~b ~Y")
                     (date->string d2 "~e ~b ~Y")))))))

  (define (format-gig gig)
    `((tr
        (td (@ (class "text-nowrap text-right")) ,(format-gig-dates gig))
        (td (literal ,(fatc:gigs:desc gig))))))

  (define (future-gigs)
    (let ((now (date-subtract-duration (current-date) (make-duration days: 1))))
      (filter (lambda (gig) (date<? now (fatc:gigs:date1 gig))) (fatc:gigs:get))))

  (define (make-gigs)
    (let ((gigs (future-gigs)))
      (unless (null? gigs)
        `((div
            (@ (class "row mt-4"))
            (section
              (@ (class "col offset-lg-2 col-lg-8 centered"))
              (h3 (@ (class "d-none")) "Events")
              (span (@ (class "h3")
                       (id    "i18n-events")))
              (table
                (@ (class "table table-hover"))
                (tbody
                  ,(map format-gig gigs)))))))))

  (define (make)
    `(,(make-pics)
      ,(make-bio)
      ,(make-gigs)))
)
