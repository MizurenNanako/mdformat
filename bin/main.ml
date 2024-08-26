(* let state_mark buf (state : Mdlexer.Lex.tok_state) =
   (match state with
   | InText -> "<!--text-->"
   | InCode true -> "<!--display code-->"
   | InCode false -> "<!--inline code-->"
   | InMath true -> "<!--display math-->"
   | InMath false -> "<!--inline math-->")
   |> Buffer.add_string buf
   ;; *)

module T = Mdtoken.Tokens.MDText
module C = Mdtoken.Tokens.MDCode
module M = Mdtoken.Tokens.MDMath

let () =
  let lexer =
    Sys.argv.(1)
    |> In_channel.open_text
    |> Sedlexing.Utf8.from_channel
    |> Mdlexer.Lex.get_token
  in
  let buf = Buffer.create 17 in
  let tmp = Mdtoken.Tokens.add2buffer buf in
  let dirty_state = ref false in
  let rec loop last_tok =
    match lexer () with
    | Text T_eof -> tmp last_tok
    | cur_tok ->
      (match last_tok, cur_tok with
       (* pangu *)
       | Text T.T_space, Text T.T_cr | Text T.T_space, Text T.T_space ->
         cur_tok |> loop
       | Text (T.T_zh _), Text (T.T_zh _)
       | Text (T.T_zh _), Text (T.T_punct _)
       | Text (T.T_zh _), Text T.T_space
       | Text (T.T_zh _), Text T.T_cr
       | Text (T.T_punct _), Text (T.T_zh _)
       | Text T.T_space, Text (T.T_zh _)
       | Text T.T_cr, Text (T.T_zh _) ->
         last_tok |> tmp;
         cur_tok |> loop
       | Text (T.T_zh _), _ | _, Text (T.T_zh _) ->
         last_tok |> tmp;
         Text T.T_space |> tmp;
         cur_tok |> loop
       (* depangu *)
       | Math M.T_space, Math M.T_space
       | Math M.T_space, Math M.T_lc
       | Math M.T_space, Math M.T_rc
       | Math M.T_space, Math (M.T_cr _)
       | Math M.T_space, Math (M.T_num _) -> cur_tok |> loop
       | Math M.T_space, Math _ ->
         if !dirty_state
         then (
           last_tok |> tmp;
           dirty_state := false)
         else ();
         cur_tok |> loop
       | Math (M.T_cmd _), Math _ ->
         last_tok |> tmp;
         dirty_state := true;
         cur_tok |> loop
       | Math _, Math _ ->
         last_tok |> tmp;
         dirty_state := false;
         cur_tok |> loop
       | _ ->
         last_tok |> tmp;
         cur_tok |> loop)
  in
  lexer () |> loop;
  Buffer.output_buffer stdout buf
;;
