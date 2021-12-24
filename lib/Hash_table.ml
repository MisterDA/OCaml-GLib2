(*
 * Copyright 2018-2020 Cedric LE MOIGNE, cedlemo@gmx.com
 * This file is part of OCaml-GLib2.
 *
 * OCaml-GLib2 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * OCaml-GLib2 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OCaml-GLib2.  If not, see <http://www.gnu.org/licenses/>.
 *)

open Ctypes
open Foreign

(*
 * https://developer.gnome.org/glib/stable/glib-Hash-Tables.html
 *)
module type DataTypes = sig
  type key

  val key : key Ctypes.typ

  type value

  val value : value Ctypes.typ
  val key_destroy_func : (key ptr -> unit) option
  val value_destroy_func : (value ptr -> unit) option
end

module Make (Data : DataTypes) = struct
  type hash = unit ptr

  let hash : hash typ = ptr void

  type key = Data.key

  let key = Data.key

  type value = Data.value

  let value = Data.value
  let key_destroy_func = Data.key_destroy_func
  let value_destroy_func = Data.value_destroy_func

  module Hash_func = GCallback.GHashFunc.Make (struct
    type t = key

    let t_typ = key
  end)

  module Key_equal_func = GCallback.GEqualFunc.Make (struct
    type t = key

    let t_typ = key
  end)

  module GHFunc = GCallback.GHFunc.Make (struct
    type t = key

    let t = key

    type t' = value

    let t' = value
  end)

  module GDestroy_notify_key = GCallback.GDestroyNotify.Make (struct
    type t = key

    let t_typ = key
  end)

  module GDestroy_notify_value = GCallback.GDestroyNotify.Make (struct
    type t = value

    let t_typ = value
  end)

  let unref = foreign "g_hash_table_unref" (hash @-> returning void)
  let remove_all = foreign "g_hash_table_remove_all" (hash @-> returning void)

  let finalise hash =
    let _finalize h =
      let () = remove_all h in
      unref h
    in
    Gc.finalise _finalize hash

  let create hash_func key_equal_func =
    let create_raw =
      foreign "g_hash_table_new"
        (Hash_func.funptr @-> Key_equal_func.funptr @-> returning hash)
    in
    let h = create_raw hash_func key_equal_func in
    let () = finalise h in
    h

  let create_full hash_func key_equal_func =
    let create_full_raw =
      foreign "g_hash_table_new_full"
        (Hash_func.funptr @-> Key_equal_func.funptr
       @-> GDestroy_notify_key.funptr @-> GDestroy_notify_value.funptr
       @-> returning hash)
    in
    let _key_destroy_func =
      match key_destroy_func with None -> fun _ -> () | Some fn -> fn
    in
    let _value_destroy_func =
      match value_destroy_func with None -> fun _ -> () | Some fn -> fn
    in
    let h =
      create_full_raw hash_func key_equal_func _key_destroy_func
        _value_destroy_func
    in
    let () = finalise h in
    h

  let insert =
    foreign "g_hash_table_insert"
      (hash @-> ptr key @-> ptr value @-> returning void)

  let size = foreign "g_hash_table_size" (hash @-> returning uint)

  let lookup =
    foreign "g_hash_table_lookup"
      (hash @-> ptr key @-> returning (ptr_opt value))

  let lookup_extended hash_table lookup_key =
    let lookup_extended_raw =
      foreign "g_hash_table_lookup_extended"
        (hash @-> ptr key
        @-> ptr (ptr_opt key)
        @-> ptr (ptr_opt value)
        @-> returning bool)
    in
    let orig_key_ptr = allocate (ptr_opt key) None in
    let value_ptr = allocate (ptr_opt value) None in
    let ret =
      lookup_extended_raw hash_table lookup_key orig_key_ptr value_ptr
    in
    let orig_key_opt = !@orig_key_ptr in
    let value_opt = !@value_ptr in
    match (ret, orig_key_opt, value_opt) with
    | true, Some orig_key, Some value -> Some (orig_key, value)
    | _ -> None

  let foreach hash_table f =
    let foreign_raw =
      foreign "g_hash_table_foreach" (hash @-> GHFunc.funptr @-> returning void)
    in
    (*
     * See DLList implementation of foreach for an explanation
     * *)
    let f_raw a b _c = f a b in
    foreign_raw hash_table f_raw
end

(*
type t
let t_typ : t structure typ = structure "Hash_table"

let add =
  foreign "g_hash_table_add" (ptr t_typ @-> ptr_opt void @-> returning (bool))
let contains =
  foreign "g_hash_table_contains" (ptr t_typ @-> ptr_opt void @-> returning (bool))
let destroy =
  foreign "g_hash_table_destroy" (ptr t_typ @-> returning (void))
let insert =
  foreign "g_hash_table_insert" (ptr t_typ @-> ptr_opt void @-> ptr_opt void @-> returning (bool))
let lookup =
  foreign "g_hash_table_lookup" (ptr t_typ @-> ptr_opt void @-> returning (ptr_opt void))
let lookup_extended hash_table lookup_key =
  let lookup_extended_raw =
    foreign "g_hash_table_lookup_extended" (ptr t_typ @-> ptr_opt void @-> ptr (ptr_opt void) @-> ptr (ptr_opt void) @-> returning (bool))
  in
  let orig_key_ptr = allocate (ptr_opt void) None in
  let value_ptr = allocate (ptr_opt void) None in
  let ret = lookup_extended_raw hash_table lookup_key orig_key_ptr value_ptr in
  let orig_key = !@ orig_key_ptr in
  let value = !@ value_ptr in
  (ret, orig_key, value)
let remove =
  foreign "g_hash_table_remove" (ptr t_typ @-> ptr_opt void @-> returning (bool))
let remove_all =
  foreign "g_hash_table_remove_all" (ptr t_typ @-> returning (void))
let replace =
  foreign "g_hash_table_replace" (ptr t_typ @-> ptr_opt void @-> ptr_opt void @-> returning (bool))
let size =
  foreign "g_hash_table_size" (ptr t_typ @-> returning (uint32_t))
let steal =
  foreign "g_hash_table_steal" (ptr t_typ @-> ptr_opt void @-> returning (bool))
let steal_all =
  foreign "g_hash_table_steal_all" (ptr t_typ @-> returning (void))
let unref =
  foreign "g_hash_table_unref" (ptr t_typ @-> returning (void))
   *)
