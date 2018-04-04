(* open Tea.App
open Tea.Html

(* Example open variants in modules: *)
(* TODO: try to unify model and AppComon model by moving `type model = ..` to Subapp *)


module AppCommon = struct
  type _ subapp = ..

  type model = ..
end

module type Subapp = sig
  type model
  type msg = ..

  val model: model 
  val update: model -> msg -> AppCommon.model
  val view: AppCommon.model -> msg Vdom.t
end

module LeftApp: sig 
  include Subapp

  type AppCommon.model += | LeftAppModel of model
  type msg += | Inc | Dec
  type _ AppCommon.subapp += | LeftApp: (msg * model) AppCommon.subapp

  val model: model
  val update: AppCommon.model -> msg -> AppCommon.model
  val view: AppCommon.model -> msg Vdom.t
end = struct
  type model = int
  type msg += | Inc: Subapp.msg | Dec: Subapp.msg 

  type AppCommon.model += | LeftAppModel of model
  (* type msg += | LeftAppMsg of msg *)
  type _ AppCommon.subapp += | LeftApp: (msg * model) AppCommon.subapp

  let model = 12

  let update (LeftAppModel model as m) = failwith "foo"
  (* function
    | Inc -> LeftAppModel (model + 1)
    | Dec -> LeftAppModel (model - 1)
    | _ -> m *)
  
  let view (LeftAppModel model) = failwith "foo"
    (* div [] [
      button [onClick Inc] [text "up"];
      button [onClick Dec] [text "down"];
      text @@ string_of_int @@ model
    ] *)
end

module RightApp: sig
  include Subapp

  type AppCommon.model += | RightAppModel of model
  type msg += | RightAppMsg of msg
  type _ AppCommon.subapp += | RightApp: (msg * model) AppCommon.subapp

  val model: model
  val update: AppCommon.model -> msg -> AppCommon.model
  val view: AppCommon.model -> msg Vdom.t
end = struct
  type model = string
  (* type msg = | AddBang *)

  type AppCommon.model += | RightAppModel of string
  type msg += | RightAppMsg of msg
  type _ AppCommon.subapp += | RightApp: (msg * model) AppCommon.subapp

  let model = "Hello!"

  let update (RightAppModel model as m) = function
    | AddBang -> RightAppModel (model ^ "!")
    | _ -> m

  let view (RightAppModel model) = 
    div [] [
      button [onClick (RightAppMsg AddBang)] [text "add !"];
      text model
    ]
end

module FullApp = struct
  (* TODO: fix escaping constructor *)
  (* let model = List.map (fun (module SA: Subapp) -> SA.model) subapps *)

  let model: (string * AppCommon.model) list = 
    [
      ("left", LeftApp.LeftAppModel LeftApp.model); 
      ("right", RightApp.RightAppModel RightApp.model)
    ]

  (* TODO: try to improve -
    - mode key inside module
    - make dynamic (maybe with GADTs?) 
    - generate from list of modules? *)
  let update (models: (string * AppCommon.model) list) msg = 
    match msg with
    | LeftApp.LeftAppMsg msg -> 
      let (key, model) = models |> List.find (fun (key, _) -> key = "left") in
      let updated_model = LeftApp.update model msg in
      let tl = List.filter (fun (key', _) -> key' <> key) models in
      (key, updated_model)::tl
    | RightApp.RightAppMsg msg -> 
      let (key, model) = models |> List.find (fun (key, _) -> key = "right") in
      let updated_model = RightApp.update model msg in
      let tl = List.filter (fun (key', _) -> key' <> key) models in
      (key, updated_model)::tl
    | _ -> models

  let view =
    function
    | LeftApp.LeftAppModel _ as m -> LeftApp.view m
    | RightApp.RightAppModel _ as m -> RightApp.view m
    | _ -> Vdom.noNode

  
end *)