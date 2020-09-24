open Incr_dom.Vdom
open Base

let take i xs =
  let rec aux acc i xs =
    match i with
    | 0 -> acc
    | k -> match xs with
      | [] -> []
      | y :: ys -> aux (y :: acc) (k - 1) ys
  in
  aux [] i xs |> List.rev

let rec drop i xs =
  match i with
  | 0 -> xs
  | k -> match xs with
    | [] -> []
    | _::ys -> drop (k - 1) ys

let index_of elt xs =
  let rec aux i elt = function
    | [] -> None
    | x :: xs -> if (phys_equal x elt) then Some i else aux (i + 1) elt xs
  in
  aux 0 elt xs

let rec parse (result : Node.t list) text_so_far chars =
  let handle_char c xs =
    parse result (text_so_far ^ (String.of_char c)) xs
  in

  let handle_bold text xs =
    let b = Node.span [ Attr.classes ["font-weight-bold"] ] [ Node.text text ] in
    parse (b :: Node.text text_so_far :: result) "" xs
  in

  let handle_open_brace xs =
    match index_of '}' xs with
    | None -> handle_char '{' xs
    | Some idx_close ->
      match index_of '{' xs with
      | Some idx_open when idx_open < idx_close -> handle_char '{' xs
      | _ -> handle_bold
               (take idx_close xs |> String.of_char_list)
               (drop (idx_close + 1) xs)
  in

  match chars with
  | []        -> Node.text text_so_far :: result
  | '{' :: xs -> handle_open_brace xs
  | x :: xs   -> handle_char x xs

let node_of_string s =
  parse [] ""  (String.to_list s) |> List.rev |> Node.p []
