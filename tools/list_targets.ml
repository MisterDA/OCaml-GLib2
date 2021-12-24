module GI = GObject_introspection
module BG = GI_bindings_generator
module Utils = BG.Binding_utils

(** Generate a list of the files generated automatically for enum and flags
 *  bindings with the gen/generator.ml bindings generator. Those files are
 *  are numerous and jbuild files need that the user specify them all the
 *  generated targets.
 **)

let file = Utils.File.create "targets"
let namespace = "GLib"

let () =
  let open GI in
  let open Utils in
  match Repository.require namespace () with
  | Error message -> print_endline message
  | Ok typelib ->
      let n = Repository.get_n_infos namespace in
      let _ =
        for i = 0 to n - 1 do
          let bi = Repository.get_info namespace i in
          match Base_info.get_name bi with
          | None -> ()
          | Some name -> (
              if Base_info.is_deprecated bi then ()
              else
                let generated_files () =
                  let module_name = BG.Lexer.snake_case name in
                  String.concat "" [ module_name; ".ml "; module_name; ".mli" ]
                in
                match Base_info.get_type bi with
                | Base_info.Enum | Base_info.Flags ->
                    let entries = generated_files () in
                    File.buff_add_line file entries
                (* print_endline entries *)
                | _ -> ())
        done
      in
      let _ = File.buff_write file in
      File.close file
