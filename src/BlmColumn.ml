open Tea.Html
open BlmNumbers
open BlmCommon
open MakeModifierHelpers

module BlmColumnInner = struct
  type column_size = 
    [ `Narrow | `Half | `OneThird | `OneQuarter | `ThreeQuarters 
    | `OneFifth | `TwoFifths | `ThreeFifths | `FourFifths 
    | column_sizes_numbers ]

  type column_size_modifier = [ `Size of column_size | `Offset of column_size ]

  type column_viewport = [ `Mobile | `Desktop | `Widescreen | `FullHD ]

  type column_responsive_modifier = [ `Is of column_size * column_viewport ]

  type columns_responsive_modifier = [ `StackUpTo of column_viewport ]

  type column_gap = [ `Gapless | `GapSize of gap_sizes_numbers ]

  type column_options =  [ `Multiline | `Centered ]

  type columns_modifier = [ column_options | column_gap | columns_responsive_modifier ]

  type column_modifier = [ column_size_modifier | column_responsive_modifier ]

  type column_related_modifier = [ columns_modifier | column_modifier ]

  (* Helpers *)

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

  (* Exported *)

  let as_class_name: column_related_modifier -> string = function
    | #column_modifier as column_mod -> 
      column_modifier_as_class_name column_mod
    | #columns_modifier as columns_mod ->
      columns_modifier_as_class_name columns_mod

  let column ?(opts=[]) content = 
    let opts_classes = List.map column_modifier_as_class_name opts in
    let props = combine_class_names ~fixed:"column" opts_classes in
    div [ props ] [ content ]

  let columns ?(opts=[]) ?(wrap=true) nodes = 
    let columns = if wrap then List.map column nodes else nodes in
    let opts_classes = List.map columns_modifier_as_class_name opts in
    let props = combine_class_names ~fixed:"columns" opts_classes in
    div [ props ] columns
end

module Helpers = MakeModiferHelpers(struct 
    include BlmColumnInner
    type t = column_related_modifier
  end)

include BlmColumnInner
include Helpers
