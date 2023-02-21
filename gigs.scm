(module (fatc gigs) (get date1 date2 desc)

  (import
    (scheme)
    (only (chicken format) sprintf)
    (only (chicken io) read-lines)
    (chicken irregex)
    (only (spiffy) root-path)
    (only (srfi-1) first second third filter-map)
    (only (srfi-19) string->date)
    (prefix (fatc markup) fatc:markup:))

  (define irx
    (let ((d '(: (= 4 num) "-" (= 2 num) "-" (= 2 num))))
      (irregex
        `(:
           (=> date1 ,d)
           (? (: ","
                 (=> date2 ,d)))
           " "(=> desc (+ any))))))

  (define (parse-line line)
    (let ((m (irregex-match irx line)))
      (if m
        (let ((date1 (irregex-match-substring m 'date1))
              (date2 (irregex-match-substring m 'date2))
              (desc (irregex-match-substring m 'desc))
              (fmt   "~Y-~m-~d"))
          (list
            (string->date date1 fmt)
            (if date2 (string->date date2 fmt) #f)
            (fatc:markup:render desc)))
        #f)))

  (define date1 first)
  (define date2 second)
  (define desc third)

  (define (get)
    (with-input-from-file
      (sprintf "~A/data/gigs.txt" (root-path))
      (lambda ()
        (filter-map parse-line (read-lines)))))
)
