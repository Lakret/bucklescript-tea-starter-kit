(** Number variants for use in Bulma modifiers *)

type numbers = 
  [ `Zero
  | `One
  | `Two
  | `Three
  | `Four
  | `Five
  | `Six
  | `Seven
  | `Eight
  | `Nine
  | `Ten
  | `Eleven ]

(** For [.column] size setting: https://bulma.io/documentation/columns/sizes/ *)
type column_sizes_numbers = 
  [ `Two
  | `Three
  | `Four
  | `Five
  | `Six
  | `Seven
  | `Eight
  | `Nine
  | `Ten
  | `Eleven ]

(** For [.columns] container gap size setting: https://bulma.io/documentation/columns/gap/ *)
type gap_sizes_numbers = 
  [ `Zero
  | `One
  | `Two
  | `Three
  | `Four
  | `Five
  | `Six
  | `Seven
  | `Eight ]

let number_as_class_name: numbers -> string = function
  | `Zero -> "0"
  | `One -> "1"
  | `Two -> "2"
  | `Three -> "3"
  | `Four -> "4"
  | `Five -> "5"
  | `Six -> "6"
  | `Seven -> "7"
  | `Eight -> "8"
  | `Nine -> "9"
  | `Ten -> "10"
  | `Eleven -> "11"
