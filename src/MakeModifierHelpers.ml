(** Functor that creates additional functions for modules exposing modifiers. *)

open Tea.Html

module type ExposingModifiers = sig 
  type t

  val as_class_name: t -> string
end

module type ModiferHelpers = sig
  type t

  (** [as_class mod] returns corresponding CSS class as TEA property for [mod]. *)
  val as_class: t -> 'a Vdom.property

  (** [combine mods] returns corresponding CSS class string for a list of modifiers [mods]. *)
  val combine: t list -> string

  (** [classList mods_with_bools] combines a list of pairs [(modifier, boolean)] to a TEA class.
      If boolean is [false], modifier will not be used in the final class. *)
  val classList: (t * bool) list -> 'a Vdom.property 
end

module MakeModiferHelpers (Modifiers: ExposingModifiers) = struct
  let as_class t = class' @@ Modifiers.as_class_name t

  let combine mods =
    mods
    |> List.map Modifiers.as_class_name
    |> String.concat " "

  let classList mods_with_bools = 
    mods_with_bools
    |> List.filter (fun (_, should_add) -> should_add)
    |> List.map fst
    |> combine
    |> class'
end
