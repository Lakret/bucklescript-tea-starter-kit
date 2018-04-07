(** General purpose modifiers (Bulma classes) *)

(** Color modifiers *)
type color_modifier = 
  [ `IsPrimary | `IsLink | `IsInfo | `IsSuccess | `IsWarning | `IsDanger 
  | `IsWhite | `IsBlack | `IsLight | `IsDark ]

(** Size modifiers *)
type size_modifier = [ `IsSmall | `IsMedium | `IsLarge ]

(** Responsiveness modifiers *)

(** Responsiveness: show only on selected viewport *)
type show_only_on = [ `Mobile | `TabletOnly | `DesktopOnly | `WidescreenOnly ]

(** Responsiveness: show only up to or from a selected viewport *)
type show_only_from = [ `UpToTouch | `Tablet | `Desktop | `Widescreen | `FullHD ]

type viewport_width = [ show_only_on | show_only_from ] 

(** Display classes for showing stuff  *)
type display_class = 
  | Block | Flex | Inline | InlineBlock | InlineFlex

(** Show or hide content based on viewport width *)
type responsive_modifier = 
  [ `ShowAs of display_class * viewport_width (** [is-block-mobile] like classess *)
  | `Hidden of viewport_width ]

(** Helper modifiers 
Docs: https://bulma.io/documentation/modifiers/helpers/ *)

type float_helper_modifier = [ `IsClearfix | `IsPulledLeft | `IsPulledRight ]

type spacing_helper_modifier = [ `IsMarginless | `IsPaddingless ]

type other_helper_modifier = 
  [ `IsOverlay | `IsClipped | `IsRadiusless | `IsShadowless | `IsUnselectable | `IsInvisible ]

type helper_modifier = [ float_helper_modifier | spacing_helper_modifier | other_helper_modifier ]

(* TODO: Typography: https://bulma.io/documentation/modifiers/typography-helpers/ *)

(** General-purpose Bulma modifier class *)
type modifier = [ color_modifier | size_modifier | helper_modifier | responsive_modifier ]

(** Helpers for working with modifiers *)

(** [as_class_name mod] returns corresponding CSS class name string for [mod]. *)
val as_class_name: modifier -> string

include MakeModifierHelpers.ModiferHelpers with type t := modifier
