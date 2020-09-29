let fetch ~url ~on_error_msg ~handler =
  let open Async_kernel in
  let handle = function
    | Result.Ok body -> handler body
    | Result.Error _ -> handler on_error_msg
  in
  don't_wait_for (Async_js.Http.get url >>| handle)
