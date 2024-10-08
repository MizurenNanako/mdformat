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
    (* Sys.argv.(1)
       |> In_channel.open_text *)
    stdin |> Sedlexing.Utf8.from_channel |> Mdlexer.Lex.get_token
  in
  let buf = Buffer.create 17 in
  let tmp = Mdtoken.Tokens.add2buffer buf in
  let rec loop dirty_state last_tok =
    let tk = lexer () in
    Mdtoken.Tokens.debug tk;
    match tk with
    | Text T_eof -> tmp last_tok
    | cur_tok ->
      (match last_tok, cur_tok with
       (* pangu *)
       | Text T.T_space, Text (T.T_cr _) | Text T.T_space, Text T.T_space ->
         cur_tok |> loop dirty_state
       | Text (T.T_zh _), Text (T.T_zh _)
       | Text (T.T_zh _), Text (T.T_punct _)
       | Text (T.T_zh _), Text T.T_space
       | Text (T.T_zh _), Text (T.T_cr _)
       | Text (T.T_punct _), Text (T.T_zh _)
       | Text T.T_space, Text (T.T_zh _)
       | Text (T.T_cr _), Text (T.T_zh _) ->
         last_tok |> tmp;
         cur_tok |> loop dirty_state
       | Text (T.T_zh _), _ | _, Text (T.T_zh _) ->
         last_tok |> tmp;
         Text T.T_space |> tmp;
         cur_tok |> loop dirty_state
       (* depangu *)
       | Math M.T_space, Math M.T_space
       | Math M.T_space, Math M.T_lc
       | Math M.T_space, Math M.T_rc
       | Math M.T_space, Math (M.T_cr _)
       | Math M.T_space, Math (M.T_num _)
       | Math M.T_space, Math (M.T_punct _)
       | Math M.T_space, Math (M.T_cmd _) -> cur_tok |> loop dirty_state
       | Math M.T_space, Math _ ->
         if dirty_state
         then (
           last_tok |> tmp;
           cur_tok |> loop false)
         else cur_tok |> loop dirty_state
       | Math (M.T_cmd _), Math _ ->
         last_tok |> tmp;
         cur_tok |> loop true
       | Math _, Math _ ->
         last_tok |> tmp;
         cur_tok |> loop false
       | _ ->
         last_tok |> tmp;
         cur_tok |> loop dirty_state)
  in
  lexer () |> loop false;
  Buffer.output_buffer stdout buf
;;
