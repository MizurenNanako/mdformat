let lexbuf = Sedlexing.Utf8.from_string "这是中文this is not" in
Mdlexer.Lex.get_token lexbuf
;;

print_newline ()
