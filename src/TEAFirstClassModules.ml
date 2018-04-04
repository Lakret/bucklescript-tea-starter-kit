open Tea.App
open Tea.Html

module GlobalIds = struct
  type dynamic_message = ..
end

module type Subapp = sig
  type model
  type msg

  val key: string
  val model: model 
  val update: model -> msg -> model
  val view: model -> msg Vdom.t
end

module type SubappWithModel = sig
  module Subapp: Subapp
  val model: Subapp.model 
end

module LeftApp: Subapp = struct
  type model = int
  type msg = | Inc | Dec

  let key = "left-subapp-key"
  let model = 12

  let update model = function
    | Inc -> model + 1
    | Dec -> model - 1
  
  let view model = 
    div [] [
      button [onClick Inc] [text "up"];
      button [onClick Dec] [text "down"];
      text @@ string_of_int @@ model
    ]
end

module RightApp: Subapp = struct
  type model = string
  type msg = | AddBang

  let key = "right-subapp-key"
  let model = "Hello!"

  let update model = function
    | AddBang -> model ^ "!"

  let view model = 
    div [] [
      button [onClick AddBang] [text "add !"];
      text model
    ]
end

module type SubappWithMsg = sig
  module Subapp: Subapp
  val msg: Subapp.msg
end

module FCMCompHelpers = struct
  let build_model_from_module (m: (module Subapp)) =
    let module Subapp = (val m: Subapp) in
    (module struct
      module Subapp = Subapp
      let model = Subapp.model
    end: SubappWithModel)

(* TODO: maybe we need to pack inside module again to return msg? *)
  (* let build_msg_from_module (m: (module SubappWithModel)) =
    let module SubappWithModel = (val m: SubappWithModel) in
    (module struct
      module Subapp = SubappWithModel.Subapp
      let viewResult = Subapp 
    end: SubappWithMsg) *)
end

module FullApp = struct
  open FCMCompHelpers
  let subapps = 
    [
      (module LeftApp: Subapp); 
      (module RightApp)
    ]

  (* representation of dynamic type with string key; 
  used for dynamic messages dispatch *)
  type dyn = | Dyn: string * 'a -> dyn

  let model = List.map build_model_from_module subapps
  (* : (module SubappWithModel) list *)

(* TODO: implement update *)
(* 'model -> 'msg -> 'model; *)
(* (module SubappWithModel) list -> dyn -> (module SubappWithModel) list *)
  let update (models: (module SubappWithModel) list) (msg: dyn) = models

  (* : (module SubappWithModel with type Subapp.msg = 'a) list -> 'a dyn Vdom.t *)
  let view (models: (module SubappWithModel) list)  = 
    let subapp_views = List.map 
      (fun (module SM: SubappWithModel) -> 
        let vdom = SM.Subapp.view SM.model in
        let dyn_msg = Vdom.map (fun vdom -> Dyn(SM.Subapp.key, vdom)) vdom in
        (SM.Subapp.key, dyn_msg))
      models
    in
    let wrapped_in_divs = List.map (fun (key, vdom) -> div [class' key] [ vdom ]) subapp_views in
    div [] wrapped_in_divs

  let app = beginnerProgram {
    model;
    update; 
    view
   }
end
