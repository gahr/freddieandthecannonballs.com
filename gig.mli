open Core_kernel

type t [@@deriving sexp, compare]

val fetch_url : string

val parse : string -> t list

val date : t -> Date.t

val desc : t -> string
