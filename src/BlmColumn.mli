(** Bulma columns helpers
https://bulma.io/documentation/columns/basics/ *)

(* TODO: column layout helper generators:
  - nested columns (https://bulma.io/documentation/columns/nesting/) *)

open Tea.Html
open BlmNumbers

(** Column size attributes used as part of [column_size_modifier] and [column_responsive_modifier]. *)
type column_size =
  [ `Narrow
  | `Half
  | `OneThird
  | `OneQuarter
  | `ThreeQuarters
  | `OneFifth
  | `TwoFifths
  | `ThreeFifths
  | `FourFifths
  | column_sizes_numbers ]

(** Modifiers that set size or offset for a column:
https://bulma.io/documentation/columns/sizes/ *)
type column_size_modifier = 
  [ `Size of column_size (** [is-...], used for column sizes  *)
  | `Offset of column_size (** [is-offset-...], used to specify offset between columns *) ]

(** Column responsiveness modifiers:
https://bulma.io/documentation/columns/responsiveness/ *)

(** Responsiveness: column viewport selectors *)
type column_viewport = 
  [ `Mobile (** [is-mobile], columns are stacked on mobile, unless this modifier is used *)
  | `Desktop (** [is-desktop], this class makes columns stack on both mobile and tablet *)
  | `Widescreen (** [is-widescreen] class *)
  | `FullHD (** [is-fullhd] class *) ]

(** Responsive size and column stacking modifiers *)

(** [is-one-quarter-desktop], [is-half-mobile], ... on column. 
Specifies sizes for different viewport widths. *) 
type column_responsive_modifier = 
  [ `Is of column_size * column_viewport ]

(** [is-mobile], [is-desktop], ... on columns container. 
Specifies on which viewports columns should be stacked *)
type columns_responsive_modifier = 
  [ `StackUpTo of column_viewport ]

(** Modifiers setting gap (or lack thereof) between columns:
https://bulma.io/documentation/columns/gap/ *)

(** [column_gap] modifiers are set on columns container. 
They change a gap between contained columns. *)
type column_gap = 
  [ `Gapless (** [is-gapless] Removes the gap between columns. *)
  | `GapSize of gap_sizes_numbers (** [is-0], ..., [is-8] custom gap modifier. 
                                      TODO: [.is-variable] class will be added automatically. *) ]

(** Additional [.columns] container modifiers:
https://bulma.io/documentation/columns/options/ *)

type column_options = 
  [ `Multiline (** [is-multiline] sets columns container to multiline mode *)
  | `Centered (** [is-centered] centers contained columns *) ]

(** Modifiers for columns container *)
type columns_modifier = [ column_options | column_gap | columns_responsive_modifier ]

(** Modifiers for columns *)
type column_modifier = [ column_size_modifier | column_responsive_modifier ]

(** All column-related modifiers (both for columns container and columns themselves). *)
type column_related_modifier = [ columns_modifier | column_modifier ]
(* type t = column_related_modifier *)

(** [as_class_name column_related_modifier] Converts [column_related_modifier] to Bulma class name. *)
val as_class_name : column_related_modifier -> string

(** [column ?opts content] Creates a column with [content] and [opts] modifiers. *)
val column : ?opts:column_modifier list -> 'a Vdom.t -> 'a Vdom.t

(** [columns ?opts ?(wrap=true) nodes] Creates a columns div with [nodes] and [opts] modifiers.
Optionally wraps [nodes] in [column]s if [?wrap] is [true] (default). *)
val columns : ?opts:columns_modifier list -> ?wrap:bool -> 'a Vdom.t list -> 'a Vdom.t

include MakeModifierHelpers.ModiferHelpers with type t := column_related_modifier
