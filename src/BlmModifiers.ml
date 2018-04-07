open Tea.Html
open BlmCommon

(* Color modifiers *)

type color_modifier = 
  [ `IsPrimary | `IsLink | `IsInfo | `IsSuccess | `IsWarning | `IsDanger 
  | `IsWhite | `IsBlack | `IsLight | `IsDark ]

(* Size modifiers *)

type size_modifier = [ `IsSmall | `IsMedium | `IsLarge ]

(* Responsiveness modifiers *)

type show_only_on = [ `Mobile | `TabletOnly | `DesktopOnly | `WidescreenOnly ]

type show_only_from = [ `UpToTouch | `Tablet | `Desktop | `Widescreen | `FullHD ]

type viewport_width = [ show_only_on | show_only_from ] 

type display_class = | Block | Flex | Inline | InlineBlock | InlineFlex

type responsive_modifier = 
  [ `ShowAs of display_class * viewport_width
  | `Hidden of viewport_width ]

(* Helper modifiers *)

type float_helper_modifier = [ `IsClearfix | `IsPulledLeft | `IsPulledRight ]

type spacing_helper_modifier = [ `IsMarginless | `IsPaddingless ]

type other_helper_modifier = [ `IsOverlay | `IsClipped | `IsRadiusless | `IsShadowless | `IsUnselectable | `IsInvisible ]

type helper_modifier = [ float_helper_modifier | spacing_helper_modifier | other_helper_modifier ]

type modifier = [ color_modifier | size_modifier | helper_modifier | responsive_modifier ]
type t = modifier

(* Helpers *)

let display_class_as_class_name = function
  | Block -> "block"
  | Flex -> "flex"
  | Inline -> "inline"
  | InlineBlock -> "inline-block"
  | InlineFlex -> "inline-flex"

let viewport_width_as_class_name: viewport_width -> string = function
  | `Mobile -> "mobile"
  | `TabletOnly -> "tablet-only"
  | `DesktopOnly -> "desktop-only"
  | `WidescreenOnly -> "widescreen-only"
  | `UpToTouch -> "touch"
  | `Tablet -> "tablet"
  | `Desktop -> "desktop"
  | `Widescreen -> "widescreen"
  | `FullHD -> "fullhd"

let show_as_as_class_name display_class (viewport_width: viewport_width) =
    [ 
      "is";
      display_class_as_class_name display_class;
      viewport_width_as_class_name viewport_width
    ]
    |> dash_join

let hidden_as_class_name (viewport_width: viewport_width) =
  [ 
    "is-hidden";
    viewport_width_as_class_name viewport_width
  ]
  |> dash_join

(* Interface *)

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
  | `ShowAs(display_class, viewport_width) -> 
    show_as_as_class_name display_class viewport_width
  | `Hidden(viewport_width) -> hidden_as_class_name viewport_width

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
