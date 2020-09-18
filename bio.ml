open Core_kernel

let fetch ~lang ~handler =
  let url = "./data/bio-" ^ (Lang.short_string_of_lang lang) ^ ".txt" in
  Url.fetch ~url ~not_found_msg:"Cannot fetch bio" ~handler
