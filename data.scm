(module (fatc data) (get)

  (import
    (scheme)
    (openssl)
    (only (chicken format) sprintf)
    (only (chicken port) copy-port)
    (only (chicken process) call-with-output-pipe)
    (only (chicken time) current-seconds)
    (only (chicken time posix) seconds->string)
    (only (http-client) call-with-input-request)
    (only (spiffy) access-log log-to root-path))

  (define (unzip in)
    (let ((s (sprintf "/usr/bin/unzip -qud ~A/data -- -" (root-path))))
      (call-with-output-pipe s (lambda (out) (copy-port in out)))))

  (define (get url)
    (log-to (access-log) "[~A] data sync'd" (seconds->string (current-seconds)))
    (call-with-input-request url #f unzip))
)
