open Tea.App
open Tea.Html

module GlobalIds = struct
  type message_type_key = ..
end

module type Subapp = sig
  type model
  type msg

  val message_type_key: GlobalIds.message_type_key
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
  open GlobalIds

  type model = int
  type msg = | Inc | Dec
  type message_type_key += | LeftAppMessageType: message_type_key
  
  let message_type_key = LeftAppMessageType
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
  open GlobalIds

  type model = string
  type msg = | AddBang
  type message_type_key += | RightAppMessageType: message_type_key
  
  let message_type_key = RightAppMessageType
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
  open GlobalIds

  module MessageTypeMap = Map.Make(struct
    type t = message_type_key
    let compare t1 t2 = compare t1 t2
  end)

(* The only thing that's need customization! *)
  let subapps = 
    [
      (module LeftApp: Subapp); 
      (module RightApp)
    ]
(* ----------------------------------------- *)

  let subapps_map =
    List.fold_left (fun acc subapp -> 
      let (module Subapp: Subapp) = subapp in
      MessageTypeMap.add Subapp.message_type_key subapp acc) 
      MessageTypeMap.empty 
      subapps

  (* representation of dynamic type with string key; 
  used for dynamic messages dispatch *)
  type dyn = 
    | Dyn: message_type_key * 'a -> dyn

  let model = List.map build_model_from_module subapps
  (* : (module SubappWithModel) list *)

(* TODO: maybe we should require that messages are always in the form string_key * message_content?
then we can create a map from string_keys to models and dispatch based on this? *)

(* TODO: implement update WITH SUBAPPS_MAP AND MESSAGE TYPE KEY HELP *)
(* IDEA: instead of sending plain 'msg, I can create a module that contains both message and corresponding update?
Still need to somehow dispatch only for model of correct type
IDEA2: Maybe we need to tag messages and models with some unique type/field, and pattern match on that? 
Than models could be a map and we can do message processing in O(1) instead of O(n).
 *)
(* 'model -> 'msg -> 'model; *)
(* (module SubappWithModel) list -> dyn -> (module SubappWithModel) list *)
  let update (models: (module SubappWithModel) list) (msg: dyn) = failwith "foo"
    (* match msg with 
    | Dyn(msg_type_key, message) ->
      (* TODO: use map instead of list find! *)
      let (module Target) = List.find (fun (module SAWM: SubappWithModel) -> 
        SAWM.Subapp.message_type_key == msg_type_key) models in 
      let updated_model = Target.Subapp.update Target.model message in
      (* TODO: need to prove that message is compatible with Target.Subapp.update. One approach is:
      https://stackoverflow.com/questions/30429552/creating-gadt-expression-in-ocaml#
      maybe: Encoding Types in ML-like Languages paper *)
      models
    | _ -> models *)

  (* : (module SubappWithModel with type Subapp.msg = 'a) list -> 'a dyn Vdom.t *)
  let view (models: (module SubappWithModel) list)  = 
    let subapp_views = List.map 
      (fun (module SM: SubappWithModel) -> 
        let vdom = SM.Subapp.view SM.model in
        let dyn_msg = Vdom.map (fun vdom -> Dyn(SM.Subapp.message_type_key, vdom)) vdom in
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
