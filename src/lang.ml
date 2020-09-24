type t = Eng | Ita [@@deriving sexp, compare, enumerate]

let string_of_lang = function
  | Eng -> "English"
  | Ita -> "Italiano"

let short_string_of_lang = function
  | Eng -> "en"
  | Ita -> "it"

let default = Eng
