let fetch ~url ~not_found_msg ~handler =
  let open Async_kernel in
  let handle = function
    | Result.Ok body -> handler body
    | Result.Error _ -> handler not_found_msg
  in
  Async_js.Http.get url >>| handle >>> fun _ -> ()

