(* find.ml
 * author: Jake Pittis
 * usage: find <directory> <?regex>
 *
 * description: Given a directory and an optional regex, print all files below
 * the given directory. If a regex is supplied, only print the path if it
 * matches the regex. Performance is near equivalent to the default `find .` on
 * osx.
 *
 * comment: I created this program because I was tired of `find . | grep 'foo'`
 * failing on large input sizes.
 *)

open Core.Std
module Re2 = Re2.Std.Re2

(* Helper functions for argument parsing and error handling. *)
let exit_with_usage ?error () =
  begin match error with
  | Some err -> Printf.printf "error: %s\n" err
  | None -> Printf.printf "usage: %s <directory> <?regex>\n" Sys.argv.(0)
  end;
  exit 1

let parse_argument index found =
  let arg = if Array.length Sys.argv > index then
    Some Sys.argv.(index) else None in
  found arg

let parse_directory arg =
  match arg with
  | Some dir -> if Sys.is_directory dir = `Yes then dir else exit_with_usage ()
  | None -> exit_with_usage ()

let parse_regex arg =
  match arg with
  | Some pattern -> begin
    match Re2.create pattern with
    | Ok reg -> Some reg
    | Error err -> exit_with_usage ~error: "failed to parse regex" ()
  end
  | None -> None

(* Calls found on all files below dir in the directory hierarchy. *)
let rec find_all_files dir found =
  let recurse_if_directory full_path =
    if Sys.is_directory full_path = `Yes
    then find_all_files full_path found
    else found full_path in
  Sys.readdir dir
  |> Array.map ~f:(Filename.concat dir)
  |> Array.iter ~f:recurse_if_directory

(* Prints the given path if it matches the given regex.
 * To be passed to find_all_files as the found argument. *)
let print_path reg =
  let should_print =
    match reg with
    | Some r -> Re2.matches r
    | None -> fun _ -> true in
  fun path -> if should_print path then
    Printf.printf "%s\n" path

let () =
  let dir = parse_argument 1 parse_directory in
  let reg = parse_argument 2 parse_regex in
  find_all_files dir (print_path reg)
