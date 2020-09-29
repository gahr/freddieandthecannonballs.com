let fetch ~lang ~handler =
  let url = "./data/bio-" ^ (Lang.short_string_of_lang lang) ^ ".txt" in
  Url.fetch ~url ~on_error_msg:"Cannot fetch bio" ~handler
