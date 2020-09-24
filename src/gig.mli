open Core_kernel

type t [@@deriving sexp, compare]

val parse : string -> t list

val date : t -> Date.t

val desc : t -> string

val no_events_msg : string

val fetch : handler:(string -> unit) -> unit
