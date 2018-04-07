(** Bulma columns helpers
https://bulma.io/documentation/columns/basics/ *)

open Tea.Html
open BlmNumbers
open BlmCommon

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

(* TODO: column layout helper generators:
  - nested columns (https://bulma.io/documentation/columns/nesting/) *)

let column_size_as_class_name: column_size -> string = function
  | `Narrow -> "narrow"
  | `Half -> "half"
  | `OneThird -> "one-third"
  | `OneQuarter -> "one-quarter"
  | `ThreeQuarters -> "three-quarters"
  | `OneFifth -> "one-fifth"
  | `TwoFifths -> "two-fifths"
  | `ThreeFifths -> "three-fifths"
  | `FourFifths -> "four-fifths"
  | #column_sizes_numbers as num -> number_as_class_name num

let viewport_as_class_name_part: column_viewport -> string = function
  | `Mobile -> "mobile"
  | `Desktop -> "desktop"
  | `Widescreen -> "widescreen"
  | `FullHD -> "fullhd"

let column_modifier_as_class_name: column_modifier -> string = function
  | `Size column_size -> 
    dash_join [ "is"; column_size_as_class_name column_size ]
  | `Offset offset_size ->
    dash_join [ "is-offset"; column_size_as_class_name offset_size ]
  | `Is(column_size, viewport) ->
    dash_join @@ [
      "is"; 
      column_size_as_class_name column_size; 
      viewport_as_class_name_part viewport ]

let columns_modifier_as_class_name: columns_modifier -> string = function
  | `StackUpTo viewport -> 
    dash_join [ "is"; viewport_as_class_name_part viewport ]
  | `Multiline -> "is-multiline"
  | `Centered -> "is-centered"
  | `Gapless -> "is-gapless"
  | `GapSize (#gap_sizes_numbers as gap_size) -> 
    dash_join [ "is";  number_as_class_name gap_size ]

let as_class_name: column_related_modifier -> string = function
  | #column_modifier as column_mod -> 
    column_modifier_as_class_name column_mod
  | #columns_modifier as columns_mod ->
    columns_modifier_as_class_name columns_mod

let column ?(opts=[]) content = 
  let opts_classes = List.map (fun opt -> class' @@ column_modifier_as_class_name opt) opts in
  let props = (class' "column")::opts_classes in
  div props [ content ]

let columns ?(opts=[]) ?(wrap=true) nodes = 
  let columns = if wrap then List.map column nodes else nodes in
  let opts_classes = List.map (fun opt -> class' @@ columns_modifier_as_class_name opt) opts in
  let props = (class' "columns")::opts_classes in
  div props columns
