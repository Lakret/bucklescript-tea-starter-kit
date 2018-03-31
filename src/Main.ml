(* This line opens the Tea.App modules into the current scope for Program access functions and types *)
open Tea.App

(* This opens the Elm-style virtual-dom functions and types into the current scope *)
open Tea.Html

module Option = Belt.Option

(* Let's create a new type here to be our main message type that is passed around *)
type msg =
  | Increment  (* This will be our message to increment the counter *)
  | Decrement  (* This will be our message to decrement the counter *)
  | Reset      (* This will be our message to reset the counter to 0 *)
  | Set of int (* This will be out message to set the counter to a specific value *)
  [@@bs.deriving {accessors}] (* This is a nice quality-of-life addon from Bucklescript, it will generate function names for each constructor name, optional, but nice to cut down on code, this is unused in this example but good to have regardless *)

(* This is optional for such a simple example, but it is good to have an `init` function to define your initial model default values, the model for Counter is just an integer *)
let init () = 4

(* This is the central message handler, it takes the model as the first argument *)
let update model = function (* These should be simple enough to be self-explanatory, mutate the model based on the message, easy to read and follow *)
  | Increment -> model + 1
  | Decrement -> model - 1
  | Reset -> 0
  | Set v -> v

(* IDEAS FOR HIGH LEVEL COMPONENTS LIBRARY AND BULMA BINDINGS *)

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

  (** replaces [class' cls] with [class' is_style cls], where [is_style] is an optional
      list of [Style.style]s. *)
  val class': ?is:Styles.style list option -> string -> 'a Vdom.property

  (** Combines multiple CSS classes (represented as string) together.  *)
  val combine_css_classes: string list -> string

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
end

(** wiring everything together: BlmStyles helpers are now available + changed [class'] fun
definition with support for [is-] css classes. *)

(* open BlmStyles
module TEAExtensions = MakeTEAExtensions(BlmStyles)
open TEAExtensions *)

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

(* This is the main callback to generate the virtual-dom.
  This returns a virtual-dom node that becomes the view, only changes from call-to-call are set on the real DOM for efficiency, this is also only called once per frame even with many messages sent in within that frame, otherwise does nothing *)
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
  

(* This is the main function, it can be named anything you want but `main` is traditional.
  The Program returned here has a set of callbacks that can easily be called from
  Bucklescript or from javascript for running this main attached to an element,
  or even to pass a message into the event loop.  You can even expose the
  constructors to the messages to javascript via the above [@@bs.deriving {accessors}]
  attribute on the `msg` type or manually, that way even javascript can use it safely. *)
let main =
  beginnerProgram { (* The beginnerProgram just takes a set model state and the update and view functions *)
    model = init (); (* Since model is a set value here, we call our init function to generate that value *)
    update;
    view;
  }
