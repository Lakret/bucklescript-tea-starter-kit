(** Common helpers for the Bulma library *)

open Tea.Html

(** [join ~sep strings] Joins [strings] list with given [sep]arator. *)
let join ~sep strings = 
  let rec inner acc = function
    | [] -> acc
    | [ str ] when acc = "" -> str
    | [ str ] -> acc ^ sep ^ str
    | hd::next::tl -> 
      let acc_with_or_without_sep = if acc = "" then "" else acc ^ sep in
      inner (acc_with_or_without_sep ^ hd ^ sep ^ next) tl
  in
  inner "" strings

(** [dash_join strings] Joins [strings] list with dashes. *)
let dash_join strings = join ~sep:"-" strings

(** [join_class_names ?fixed class_names] Returns a string with combined class of [class_names].
    If [?fixed] is provided, it will be placed before [class_names] in the result. *)
let join_class_names ?(fixed="") class_names = 
  let class_names_to_join = if fixed = "" then class_names else fixed::class_names in
  join ~sep:" " class_names_to_join

(** [names_to_classes ?fixed class_names] Transforms a list of string class names to a list of classes.
    If [?fixed] is provided, it will be placed before [class_names] in the result. *)
let names_to_classes ?(fixed="") class_names = 
  let class_names = if fixed = "" then class_names else fixed::class_names in
  List.map class' class_names

(** [combine_class_names ?fixed class_names] Combines a list of string class names to a TEA class.
    If [?fixed] is provided, it will be placed before [class_names] in the resulting class. *)
let combine_class_names ?(fixed="") class_names =
  join_class_names ~fixed class_names
  |> class'
