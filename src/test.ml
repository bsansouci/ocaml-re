open OcamlRe

let re_empty = Re_posix.compile_pat "^a+"

let l = (Re.matches re_empty "aaaaab")

let _ = List.iter (fun v -> print_endline v) l
