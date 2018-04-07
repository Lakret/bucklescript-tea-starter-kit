(** [BlmContainer] is a base module for all containers.  *)

type t

(** type for [content] of the container *)
type content

(** [children t] is a list of all nested containers *)
val children: t -> t list

(** [content t] returns raw representation of the container [t]'s content. *)
val content: t -> content

(** list of [modifiers t] applied on the container *)
val modifiers: t -> BlmModifiers.modifier list
