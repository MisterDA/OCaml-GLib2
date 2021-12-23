(lang dune 2.9)
(name gi-glib2)
(formatting disabled)
(generate_opam_files true)
(use_standard_c_and_cxx_flags true)
(source (github cedlemo/OCaml-GLib2))
(authors "Cédric Le Moigne <cedlemo@gmx.com>")
(maintainers "Cédric Le Moigne <cedlemo@gmx.com>")
(license "GPL-3.0-or-later")
(package
 (name gi-glib2)
 (synopsis "OCaml bindings (auto-generated using gi-bindings-generator) for GLib2")
 (depends
  (dune-configurator :build)
  (sexplib0 :build)
  ctypes
  ctypes-foreign
  gobject-introspection
  gi-bindings-generator
  memcpy
  (ounit2 :with-test)))
