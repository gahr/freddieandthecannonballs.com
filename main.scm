(module main ()

  (import
    (scheme)
    (only (chicken process-context) command-line-arguments executable-pathname)
    (only (chicken pathname) pathname-directory)
    (only (srfi-1) find find-tail)
    (only (awful) awful-start)
    (prefix (spiffy) sp:)
    (prefix (site) site:))

  (let* ((path (pathname-directory (executable-pathname)))
         (args (command-line-arguments))
         (get-arg (lambda (name default)
                    (let ((found (find-tail (lambda (elem) (equal? name elem))
                                            args)))
                      (if found (cadr found) default))))
         (get-flag (lambda (name)
                     (find (lambda (elem) (equal? name elem)) args)))
         (addr (get-arg  "-addr" "127.0.0.1"))
         (port (get-arg  "-port" "8080"))
         (alog (get-arg  "-access-log" (string-append path "/access.log")))
         (dlog (get-arg  "-debug-log" #f))
         (elog (get-arg  "-error-log" (string-append path "/error.log")))
         (dev  (get-flag "-dev")))

    (sp:root-path (string-append path "/static"))
    (if alog (sp:access-log alog))
    (if dlog (sp:debug-log dlog))
    (if elog (sp:error-log elog))
    (awful-start
      site:run
      dev-mode?: dev
      ip-address: addr
      port: (string->number port)))
  )
