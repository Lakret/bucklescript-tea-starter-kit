open Tea.App
open Tea.Html

module Option = Belt.Option

type msg = ..
type msg +=
  | Increment
  | Decrement
  | Reset
  | Set of int
  [@@bs.deriving {accessors}]

let init () = (4, Tea_cmd.none)

let update model = 
  function
  | Increment -> model + 1
  | Decrement -> model - 1
  | Reset -> 0
  | Set v -> v
  | _ -> model

(* IDEAS FOR HIGH LEVEL COMPONENTS LIBRARY AND BULMA BINDINGS *)

(* https://caml.inria.fr/pub/docs/manual-ocaml/extn.html#sec265 *)
(* type extensible_message = ..
type extensible_message += Msg1 | Msg2
type extensible_message += Msg3 of float * string *)

type union_model = ..

(* Left module *)
type union_model += | LMM of string
type left_module_msg = [ `LM1 | `LM2 of string ]
let left_module_update model msg = 
  match model with
  | LMM _ -> begin
    match msg with
    | `LM1 -> Some model
    | `LM2 msg_state -> Some (LMM msg_state)
    | _ -> None
  end 
  | _ -> None
let left_view =
  function
  | LMM state -> 
    Some (text state)
  | _ -> None

(* Right module *)
type union_model += | RMM of int
type right_module_msg = [ `RM1 | `RM2 of int ]
let right_module_update model msg = 
  match model with
  | RMM state -> begin
    match msg with
    | `RM1 -> Some (RMM (state + 1))
    | `RM2 msg_state -> Some (RMM msg_state)
    | _ -> None
  end 
  | _ -> None
let right_view = 
  function
  | RMM state -> 
    Some (text @@ string_of_int @@ state)
  | _ -> None

(* Tying them up *)
type union_msg = [ left_module_msg | right_module_msg ]
let update_funs = [ left_module_update; right_module_update]
let apply_updates models msg = 
  models 
  |> List.fold_left 
    (fun updated_models model ->
      let current_updated = List.map (fun uf -> uf model msg) update_funs in
      let updated_model = List.find Option.isSome current_updated in
      (Option.getExn updated_model)::updated_models)
    []
 
(* TODO: what's the type of test view? maybe we need to make union_msg an open ADT as well and message type should be a list of those?

TODO: another approach is to make union_msg as open GADT where GADT's type parameter is corresponding model

TODO: or maybe we should use First Class modules (probably!)?  *)
let test_view _ = h1 [] [text "foo"]
  (* let lv = 
  div [] [

  ] *)


let test_prg: Web.Node.t Js.null_undefined -> unit -> union_msg programInterface = 
  beginnerProgram {
    model = [LMM "startState"; RMM 0];
    update = apply_updates;
    view = test_view
  }


(* TODO: Scaling ELM architecture with First Class Modules *)


module type Subapp = sig
  type msg
  type model

  val model: model
  val update: model -> msg -> model
  val view: model -> msg Vdom.t
end

module type FullSubapp = sig
  include Subapp

  type flags

  val init: flags -> model * msg Tea_cmd.t
  val updateFull: model -> msg -> model * msg Tea_cmd.t
  val subscriptions: model -> msg Tea_sub.t
end

module type SubappInstance = sig
  module Subapp: Subapp

  val model: Subapp.model
end

module LeftSubapp: Subapp = struct
  type msg = | Up | Down
  type model = int

  let model = 12
  let update model =
    function
    | Up -> model + 1
    | Down -> model - 1

  let view model = 
    div [] [
      button [onClick Up] [text "up"];
      button [onClick Down] [text "down"];
      text @@ string_of_int @@ model
    ]
end

module RightSubapp: Subapp = struct
  type msg = | Add
  type model = string

  let model = "some string"
  let update model =
    function
    | Add -> model ^ "!"

  let view model = 
    div [] [
      button [onClick Add] [text "add !"];
      text model
    ]
end




(** [BlmStyles] module and module type provide helper for [is-] and [has-] css classes. 
We use polymorphic variants to share labels between different variant types. *)
module BlmStyles: sig
  type color_style = 
    [ | `IsPrimary | `IsLink | `IsInfo | `IsSuccess | `IsWarning | `IsDanger ]
  type size_style =
    [ | `IsSmall | `IsMedium | `IsLarge ]
  type style = [ color_style | size_style ]

  val is_to_style: style -> string
  val size_style_as_string: size_style -> string
end = struct
  type color_style = 
    [ | `IsPrimary | `IsLink | `IsInfo | `IsSuccess | `IsWarning | `IsDanger ] 
  type size_style =
    [ | `IsSmall | `IsMedium | `IsLarge ]
  type style = [ color_style | size_style ]

  let is_to_style =
    function
    | `IsPrimary -> "is-primary"
    | `IsLink -> "is-link"
    | `IsInfo -> "is-info"
    | `IsSuccess -> "is-success"
    | `IsWarning -> "is-warning"
    | `IsDanger -> "is-danger"
    | `IsSmall -> "is-small"
    | `IsLarge -> "is-large"
    | `IsMedium -> "is-medium"

  let size_style_as_string = 
    function
    | `IsSmall -> "small"
    | `IsMedium -> "medium"
    | `IsLarge -> "large"
end

(** Functor parameter type. Specifies common interface for Styles modules.  *)
module type Styles = sig
  type style
  val is_to_style: style -> string
end

(** Makes an extension and/or shadows functions from Tea.Html; 
extension is parametrized by styles module *)
module MakeTEAExtensions(Styles: Styles): sig
  type t

  (** replaces [class' cls] with [class' is_style cls], where [is_style] is an optional
      list of [Style.style]s. *)
  val class': ?is:Styles.style list option -> string -> 'a Vdom.property

  (** Combines multiple CSS classes (represented as string) together.  *)
  val combine_css_classes: string list -> string

  val getT: unit -> t

end = struct
  (* Helpers *)

  let combine_css_classes classes = 
   List.fold_left (fun acc elem -> acc ^ " " ^ elem) "" classes

  let is_styles_to_classes ~is = 
    Option.map is (fun is_styles -> 
      is_styles 
      |> List.map Styles.is_to_style 
      |> combine_css_classes)
    |. Option.getWithDefault ""

  (* API *)

  let class' ?is cls =
    let add_styles = 
      match is with
      | None -> ""
      | Some styles -> " " ^ is_styles_to_classes ~is:styles
    in
    class' @@ cls ^ add_styles

  type t = int
  let getT () = 12
end

(** wiring everything together: BlmStyles helpers are now available + changed [class'] fun
definition with support for [is-] css classes. *)

open BlmStyles
module TEAExtensions = MakeTEAExtensions(BlmStyles)

(* Functors are applicative in OCaml:

module TEAExtensions2 = MakeTEAExtensions(BlmStyles)
let foo = 
  let t1 = TEAExtensions.getT in
  let t2 = TEAExtensions2.getT in
  t1 == t2
  
Can make them generative (so that TEAExtension.t will not be the same as TEAExtension2.t) by adding () after frist
functor parameter and passing it on modules generation. *)

open! TEAExtensions

(* This is just a helper function for the view, a simple function that returns a button based on some argument *)

let view_button ?is title msg =
  let is_style_classes =
    Option.map is (fun is_styles -> 
      is_styles 
      |> BlmModifiers.combine)
    |. Option.getWithDefault ""
  in
  button
    [ onClick msg; class' @@ "button " ^ is_style_classes ]
    [ text title ]

let b_columns ?classes cols =
  let make_col col = div [class' "column"] [ col ] in
  let classes = match classes with | None -> "" | Some classes -> " " ^ classes in
  let cols = List.map make_col cols in
  div 
    [class' @@ "columns" ^ classes]
    cols

let make_level ~props ~left_items ~right_items =
  let props = (class' "level") :: props in
  let make_item item = div [class' "level-item"] [ item ] in
  let left_items = List.map make_item left_items in
  let right_items = List.map make_item right_items in
  nav
    props
    [ 
      div 
      [class' "level-left"] 
      left_items;

      div 
      [class' "level-right"] 
      right_items
    ]

let view_model model = 
  b_columns ~classes:"is-vcentered" [
    span
      [ class' "is-bold box has-text-centered"; style "font-size" "10em" ]
      [ text (string_of_int model) ]
  ]

let hero () =
  section 
    [class' "hero is-primary is-bold"]
    [
      div 
        [class' "hero-body"]
        [
          div 
          [class' "container"]
          [
            h1 [] [text "Bucklescript test"];
            h2 [] [text "with Bulma!"]
          ]
        ]
    ]

let show_if cond node = if cond then node else noNode

let view model =
  (* let open BlmModifiers in *)
  div 
    [class' "section"]
    [
      hero (); br [];

      view_model model;

      make_level
        ~props:[]
        ~left_items:[
          view_button ~is:[`IsPrimary; `IsLarge; `IsRadiusless ] "Increment" Increment;
          view_button ~is:[`IsInfo; `IsLarge ] "Decrement" Decrement;
        ] 
        ~right_items:[
          view_button ~is:[`IsWarning; `IsLarge] "Set to 42" (Set 42);

          show_if (model <> 0) @@ 
            view_button ~is:[`IsDanger; `IsLarge] "Reset" Reset 
        ];
    ]

let main = TEAFirstClassModules.FullApp.app

  (* beginnerProgram {
    model; update; view
  } *)
(* 
  standardProgram {
    init;
    update = (fun model msg -> (update model msg, Tea_cmd.none));
    view;
    subscriptions = (fun _model -> Tea_sub.none)
  } *)
