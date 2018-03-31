type color_modifier = 
  [ `IsPrimary | `IsLink | `IsInfo | `IsSuccess | `IsWarning | `IsDanger 
  | `IsWhite | `IsBlack | `IsLight | `IsDark ]

type size_modifier = [ `IsSmall | `IsMedium | `IsLarge ]

(* Helper modifiers 
Docs: https://bulma.io/documentation/modifiers/helpers/ *)

type float_helper_modifier = [ `IsClearfix | `IsPulledLeft | `IsPulledRight ]

type spacing_helper_modifier = [ `IsMarginless | `IsPaddingless ]

type other_helper_modifier = [ `IsOverlay | `IsClipped | `IsRadiusless | `IsShadowless | `IsUnselectable | `IsInvisible ]

type helper_modifier = [ float_helper_modifier | spacing_helper_modifier | other_helper_modifier ]

(* TODO: 

Responsive: https://bulma.io/documentation/modifiers/responsive-helpers/
Typography: https://bulma.io/documentation/modifiers/typography-helpers/ *)

type modifier = [color_modifier | size_modifier | helper_modifier ]
type t = modifier

(* Helpers for working with modifiers *)

(** [as_class mod] returns corresponding CSS class as TEA property for [mod].  *)
val as_class: modifier -> 'a Vdom.property

(** [as_class_name mod] returns corresponding CSS class name string for [mod]. *)
val as_class_name: modifier -> string

(** [combine mods] returns corresponding CSS class string for a list of modifiers [mods]. *)
val combine: modifier list -> string

(** [classList mods_with_bools] combines a list of pairs [(modifier, boolean)] to a TEA class.
    If boolean is [false], modifier will not be used in the final class.  *)
val classList: (modifier * bool) list -> 'a Vdom.property
