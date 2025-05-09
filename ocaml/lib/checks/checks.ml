open Utilities.Aliases

(*
   The purpose of this module is to run multiple checks at appropriate times.
   All functions should end with a call to exit, which will print error messages
   and quit with code schema.meta.status if schema.meta.error_level is Fatal.

   When adding checks, consider that the error message will be overriten if exit
   is not called between schema changes. This should be improved later so that a
   list instead is printed entirely by exit, and then emptied.
*)

let exit (schema: Schema.schema): Schema.schema =
    if schema.output.main <> "" then print_endline schema.output.main;
    if schema.output.log <> "" then elog schema.output.log;
    if schema.meta.error_level == Fatal then exit schema.meta.status
    else schema

let post_config (schema: Schema.schema): Schema.schema =
    System.Process.Su.is_executable schema
    |> exit

