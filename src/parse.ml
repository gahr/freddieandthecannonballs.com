open Incr_dom.Vdom
open Base

let rec parse (result : Node.t list) text_so_far chars =
  let handle_char c xs =
    parse result (text_so_far ^ (String.of_char c)) xs
  in

  let handle_bold text xs =
    let b = Node.span [ Attr.classes ["font-weight-bold"] ] [ Node.text text ] in
    parse (b :: Node.text text_so_far :: result) "" xs
  in

  let handle_open_brace xs =
    let is_open _ x = Char.(x = '{') in
    let is_close _ x = Char.(x = '}') in

    match List.findi xs ~f:is_close with
    | None -> handle_char '{' xs
    | Some (idx_close, _) ->
      match List.findi xs ~f:is_open with
      | Some (idx_open, _) when idx_open < idx_close -> handle_char '{' xs
      | _ -> handle_bold
               (List.take xs idx_close |> String.of_char_list)
               (List.drop xs (idx_close + 1))
  in

  match chars with
  | []        -> Node.text text_so_far :: result
  | '{' :: xs -> handle_open_brace xs
  | x :: xs   -> handle_char x xs

let node_of_string s =
  parse [] ""  (String.to_list s) |> List.rev |> Node.p []
