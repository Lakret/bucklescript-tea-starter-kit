open Tea.Html

type color_modifier = 
  [ `IsPrimary | `IsLink | `IsInfo | `IsSuccess | `IsWarning | `IsDanger 
  | `IsWhite | `IsBlack | `IsLight | `IsDark ]

type size_modifier = [ `IsSmall | `IsMedium | `IsLarge ]

type float_helper_modifier = [ `IsClearfix | `IsPulledLeft | `IsPulledRight ]

type spacing_helper_modifier = [ `IsMarginless | `IsPaddingless ]

type other_helper_modifier = [ `IsOverlay | `IsClipped | `IsRadiusless | `IsShadowless | `IsUnselectable | `IsInvisible ]

type helper_modifier = [ float_helper_modifier | spacing_helper_modifier | other_helper_modifier ]

type modifier = [color_modifier | size_modifier | helper_modifier ]
type t = modifier

let as_class_name: modifier -> string = function
  | `IsPrimary -> "is-primary"
  | `IsLink -> "is-link"
  | `IsInfo -> "is-info"
  | `IsSuccess -> "is-success"
  | `IsWarning -> "is-warning"
  | `IsDanger -> "is-danger"
  | `IsWhite -> "is-white"
  | `IsBlack -> "is-black"
  | `IsLight -> "is-light"
  | `IsDark -> "is-dark"
  | `IsSmall -> "is-small"
  | `IsMedium -> "is-medium"
  | `IsLarge -> "is-large"
  | `IsClearfix -> "is-clearfix"
  | `IsPulledLeft -> "is-pulled-left"
  | `IsPulledRight -> "is-pulled-right"
  | `IsMarginless -> "is-marginless"
  | `IsPaddingless -> "is-paddingless"
  | `IsOverlay -> "is-overlay"
  | `IsClipped -> "is-clipped"
  | `IsRadiusless -> "is-radiusless"
  | `IsShadowless -> "is-shadowless"
  | `IsUnselectable -> "is-unselectable"
  | `IsInvisible -> "is-invisible"

let as_class t = class' @@ as_class_name t

let combine mods =
  mods
  |> List.map as_class_name
  |> String.concat " "

let classList mods_with_bools = 
  mods_with_bools
  |> List.filter (fun (_, should_add) -> should_add)
  |> List.map fst
  |> combine
  |> class'
