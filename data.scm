(module (fatc data) (get)

  (import
    (scheme)
    (chicken base)
    (chicken format)
    (chicken port)
    (chicken process)
    (openssl)
    (http-client)
    (only (spiffy) root-path))

  (define (unzip in)
    (let ((s (sprintf "/usr/bin/unzip -qud ~A/data -- -" (root-path))))
      (printf "cmd: ~A" s)
      (call-with-output-pipe s (lambda (out) (copy-port in out)))))

  (define (get url)
    (call-with-input-request url #f unzip))
)
