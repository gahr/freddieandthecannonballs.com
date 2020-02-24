type t = Eng | Ita [@@deriving sexp, compare, enumerate]

let string_of_lang lang =
  match lang with
  | Eng -> "English"
  | Ita -> "Italiano"

let default = Eng
