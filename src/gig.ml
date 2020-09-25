open Core_kernel

type t = 
  { date : Date.t
  ; desc : string
  } [@@deriving sexp, compare]

let date g = g.date

let desc g = g.desc

let no_events_msg = "No events scheduled at this time."

let parse s =
  (* yyyy-mm-dd desc foo bar baz *)
  let date_len = 10 in
  let maybe_gig l =
    let maybe_date =
      try Some (Date.of_string (String.prefix l date_len))
      with Invalid_argument _ -> None
    in
    let maybe_desc =
      match (String.length l > (date_len + 1)) with
      | true  -> Some (String.drop_prefix l (date_len + 1))
      | false -> None
    in
    let open Option.Let_syntax in
    let%bind date = maybe_date in
    let%bind desc = maybe_desc in
    Some { date; desc }
  in
  let gigs = List.filter_map (String.split_lines s) ~f:maybe_gig in
  List.sort gigs ~compare:(fun lhs rhs -> Date.(compare lhs.date rhs.date))

let fetch ~handler =
  Url.fetch ~url:"./data/gigs.txt" ~on_error_msg:no_events_msg ~handler
