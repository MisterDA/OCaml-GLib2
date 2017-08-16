open Ctypes

type t
val t_typ : t structure typ
val f_seq_id: (Unsigned.uint64, t structure) field
val f_hook_size: (Unsigned.uint32, t structure) field
val f_is_setup: (Unsigned.uint32, t structure) field
val f_hooks: (Hook.t structure ptr, t structure) field
val f_dummy3: (unit ptr, t structure) field
(* TODO Struct field HookList : callback tag not implemented . *)
(* TODO Struct field HookList : C Array type for GITypes.Array tag tag not implemented . *)
val clear:
t structure ptr -> unit
val init:
t structure ptr -> Unsigned.uint32 -> unit
val invoke:
t structure ptr -> bool -> unit
val invoke_check:
t structure ptr -> bool -> unit

