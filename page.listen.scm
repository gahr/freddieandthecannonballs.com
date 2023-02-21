(module (page listen) (path make)

  (import
    (scheme)
    (only (chicken base) parameterize)
    (only (chicken format) sprintf)
    (only (srfi-1) iota)
    (awful))

  (define path "33829ea9-e4cc-11ec-a758-001a4a7ec6be")

  (define (make-songs)
    (let* ((songs #( "Cannonballs!"
                     "The Proof Is In The Pudding"
                     "Let Me Sleep"
                     "yOur Pain"
                     "Barking Up The Wrong Tree"
                     "Mosquito"
                     "Unsung Hero"
                     "Banana"
                     "We Shall Not Be Moved" ))
           (nof-songs (vector-length songs))
           (make-one
             (lambda (i)
               (let* ((song (vector-ref songs (- i 1)))
                      (path (sprintf "data/TwoSidesOfTheSameCoin/~A. ~A.mp3" i song)))
                 `(li
                    (button
                      (@ (class   "btn btn-sm mr-1")
                         (type    "button")
                         (id      ,(sprintf "song-btn-~A" i))
                         (onclick ,(sprintf "play(~A, ~A)" i nof-songs)))
                      (literal "&#x23EF;"))
                    (span (@ (id ,(sprintf "song-title-~A" i))) ,song)
                    " "
                    (audio
                      (@ (id ,(sprintf "song-~A" i)))
                      (source (@ (src ,path)) (type "audio/mpeg"))))))))
      `((ol ,(map make-one (iota (vector-length songs) 1))))))

  (define (make)
    `(
      ,(include-javascript '("play.js"))
      (div
        (@ (class "row mt-3"))

        ; Cover
        (section
          (@ (class "col-md mt-3"))
          (h3 (@ (class " d-none") "Album cover"))
          (img
            (@ (class "img-fluid img-thumbnail")
               (src   "img/twosides.png")
               (alt   "Two sides of the same coin"))))


        ; Download
        (section
          (@ (class "col-md mt-3"))
          (h3 (@ (class " d-none") "Downloads"))
          ,(make-songs)
          (p
            (span (@ (id "i18n-download")))
            " "
            (a
              (@ (href "data/TwoSidesOfTheSameCoin/FreddieAndTheCannonballs-TwoSidesOfTheSameCoin.zip"))
              (span (@ (id "i18n-here"))))
            ".")))))
)
