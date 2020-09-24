type t = Eng | Ita [@@deriving sexp, compare, enumerate]

val string_of_lang : t -> string

val short_string_of_lang : t -> string

val default : t

val all : t list