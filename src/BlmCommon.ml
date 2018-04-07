(** Common helpers for the Bulma library *)

(** [join ~sep strings] Joins [strings] list with given [sep]arator. *)
let join ~sep strings = 
  let rec inner acc = function
    | [] -> acc
    | [ str ] when acc = "" -> str
    | [ str ] -> acc ^ sep ^ str
    | hd::next::tl -> inner (acc ^ sep ^ hd ^ sep ^ next) tl
  in
  inner "" strings

(** [dash_join strings] Joins [strings] list with dashes. *)
let dash_join strings = join ~sep:"-" strings
