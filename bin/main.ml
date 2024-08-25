let state_mark buf (state : Mdlexer.Lex.tok_state) =
  (match state with
   | InText -> "<!--text-->"
   | InCode true -> "<!--display code-->"
   | InCode false -> "<!--inline code-->"
   | InMath true -> "<!--display math-->"
   | InMath false -> "<!--inline math-->")
  |> Buffer.add_string buf
;;

let () =
  let lexer, state_reader =
    Sys.argv.(1)
    |> In_channel.open_text
    |> Sedlexing.Utf8.from_channel
    |> Mdlexer.Lex.get_token
  in
  let buf = Buffer.create 17 in
  let rec loop (last_state : Mdlexer.Lex.tok_state) =
    match lexer () with
    | Text T_eof -> ()
    | tk ->
      Mdtoken.Tokens.add2buffer buf tk;
      (* Buffer.add_char buf '\n'; *)
      let cur_state = state_reader () in
      (match last_state = cur_state with
       | true -> ()
       | false -> state_mark buf cur_state);
      loop cur_state
  in
  loop Mdlexer.Lex.InText;
  Buffer.output_buffer stdout buf
;;
