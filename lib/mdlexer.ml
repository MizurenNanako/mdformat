module Cat = Sedlex_ppx.Unicode.Categories

module Lex = struct
  let zh_punct =
    [%sedlex.regexp?
      ( 0X00B7 (* · *)
      | 0X2014 (* — *)
      | 0X2018 (* ‘ *)
      | 0X2019 (* ’ *)
      | 0X201C (* “ *)
      | 0X201D (* ” *)
      | 0X2026 (* … *)
      | 0X3001 (* 、 *)
      | 0X3002 (* 。 *)
      | 0X3003 (* 〃 *)
      | 0X3004 (* 〄 *)
      | 0X3005 (* 々 *)
      | 0X3006 (* 〆 *)
      | 0X3007 (* 〇 *)
      | 0X3008 (* 〈 *)
      | 0X3009 (* 〉 *)
      | 0X300A (* 《 *)
      | 0X300B (* 》 *)
      | 0X300C (* 「 *)
      | 0X300D (* 」 *)
      | 0X300E (* 『 *)
      | 0X300F (* 』 *)
      | 0X3010 (* 【 *)
      | 0X3011 (* 】 *)
      | 0X3012 (* 〒 *)
      | 0X3013 (* 〓 *)
      | 0X3014 (* 〔 *)
      | 0X3015 (* 〕 *)
      | 0X3016 (* 〖 *)
      | 0X3017 (* 〗 *)
      | 0X3018 (* 〘 *)
      | 0X3019 (* 〙 *)
      | 0X301A (* 〚 *)
      | 0X301B (* 〛 *)
      | 0X301C (* 〜 *)
      | 0X301D (* 〝 *)
      | 0X301E (* 〞 *)
      | 0X301F (* 〟 *)
      | 0XFF01 (* ！ *)
      | 0XFF08 (* （ *)
      | 0XFF09 (* ） *)
      | 0XFF0C (* ， *)
      | 0XFF1A (* ： *)
      | 0XFF1B (* ； *)
      | 0XFF5E (* ～ *) )]
  ;;

  let en_punct = [%sedlex.regexp? Chars ".,<>?/;:'\"[]{}()-=_+*&^%$#@!`~\\|"]
  let num = [%sedlex.regexp? '0' .. '9']
  let space = [%sedlex.regexp? ' ' | '\t']
  let cr = [%sedlex.regexp? '\n']
  let dl = [%sedlex.regexp? "$"]
  let bt = [%sedlex.regexp? "`"]
  let ddl = [%sedlex.regexp? "$$"]
  let tbt = [%sedlex.regexp? "```"]
  let punct = [%sedlex.regexp? zh_punct | en_punct]
  let zh = [%sedlex.regexp? Sub (0x4E00 .. 0x9FFF, zh_punct)]
  let en = [%sedlex.regexp? Sub (0x0080 .. 0x024F, en_punct)]

  let tok_text (lexbuf : Sedlexing.lexbuf) =
    let open Mdtoken.Tokens.MDText in
    let getch = Sedlexing.lexeme_char lexbuf in
    match%sedlex lexbuf with
    | zh -> T_zh (getch 0)
    | en -> T_eng (getch 0)
    | space -> T_space
    | cr, Star space -> T_cr (Sedlexing.lexeme_length lexbuf - 1)
    | num -> T_num (getch 0)
    | ddl -> T_ddollor
    | dl -> T_dollor
    | tbt -> T_tbacktick
    | bt -> T_backtick
    | punct -> T_punct (getch 0)
    | eof -> T_eof
    | any -> T_other (Sedlexing.Utf8.lexeme lexbuf)
    | _ -> assert false
  ;;

  let alpha = [%sedlex.regexp? 'A' .. 'Z' | 'a' .. 'z']
  let cmd = [%sedlex.regexp? "\\", Plus alpha]

  let tok_math (lexbuf : Sedlexing.lexbuf) =
    let open Mdtoken.Tokens.MDMath in
    let getch = Sedlexing.lexeme_char lexbuf in
    match%sedlex lexbuf with
    | "\\$" -> T_word (getch 0)
    | dl -> T_dollor
    | ddl -> T_ddollor
    | cmd -> T_cmd (Sedlexing.Utf8.lexeme lexbuf)
    | num -> T_num (getch 0)
    | "{" -> T_lc
    | "}" -> T_rc
    | en_punct -> T_punct (getch 0)
    | eof -> raise @@ Failure "unexpected eof in math mode"
    | space -> T_space
    | Plus cr, Star space -> T_cr (Sedlexing.lexeme_length lexbuf - 1)
    | any -> T_word (getch 0)
    | _ -> assert false
  ;;

  let tok_code (lexbuf : Sedlexing.lexbuf) =
    let open Mdtoken.Tokens.MDCode in
    let getch = Sedlexing.lexeme_char lexbuf in
    match%sedlex lexbuf with
    | bt -> T_backtick
    | tbt -> T_tbacktick
    | cr -> T_cr
    | space -> T_space (getch 0)
    | eof -> raise @@ Failure "unexpected eof in code mode"
    | any -> T_code (getch 0)
    | _ -> assert false
  ;;

  type tok_state =
    | InText
    | InCode of bool
    | InMath of bool

  let get_token lexbuf =
    let state = ref InText in
    fun () ->
      match !state with
      | InText ->
        let tok = tok_text lexbuf in
        (match tok with
         | T_dollor -> state := InMath false
         | T_ddollor -> state := InMath true
         | T_backtick -> state := InCode false
         | T_tbacktick -> state := InCode true
         | _ -> ());
        Mdtoken.Tokens.Text tok
      | InCode display ->
        let tok = tok_code lexbuf in
        (match tok with
         | T_backtick -> if display then () else state := InText
         | T_tbacktick ->
           if display then state := InText else raise @@ Failure "unmatched fence"
         | _ -> ());
        Mdtoken.Tokens.Code tok
      | InMath display ->
        let tok = tok_math lexbuf in
        (match tok with
         | T_dollor -> if display then () else state := InText
         | T_ddollor ->
           if display then state := InText else raise @@ Failure "unmatched fence"
         | _ -> ());
        Mdtoken.Tokens.Math tok
  ;;
end
