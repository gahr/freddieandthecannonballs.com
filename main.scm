(module main ()

  (import
    (scheme)
    (only (chicken process-context) command-line-arguments executable-pathname)
    (only (srfi-1) find-tail)
    (only (awful) awful-start)
    (prefix (spiffy) sp:)
    (prefix (site) site:))

  (let* ((args (command-line-arguments))
         (get-arg (lambda (name default)
                    (let ((found (find-tail (lambda (elem) (equal? name elem))
                                            args)))
                      (if found (cadr found) default))))
         (path (get-arg "-path" (executable-pathname)))
         (addr (get-arg "-addr" "127.0.0.1"))
         (port (get-arg "-port" "8080"))
         (dev  (get-arg "-dev" #f))
         (alog (get-arg "-access-log" #f))
         (dlog (get-arg "-debug-log" #f))
         (elog (get-arg "-error-log" #f)))

    (sp:root-path path)
    (if alog (sp:access-log alog))
    (if dlog (sp:debug-log dlog))
    (if elog (sp:error-log elog))
    (awful-start
      site:run
      dev-mode?: dev
      ip-address: addr
      port: (string->number port)))
  )
