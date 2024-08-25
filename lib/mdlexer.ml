module Cat = Sedlex_ppx.Unicode.Categories

module Lex = struct
  let zh_punct =
    [%sedlex.regexp?
      ( 0XFF0C (* ， *)
      | 0X3002 (* 。 *)
      | 0XFF1A (* ： *)
      | 0XFF1B (* ； *)
      | 0X2018 (* ‘ *)
      | 0X2019 (* ’ *)
      | 0X201C (* “ *)
      | 0X201D (* ” *)
      | 0X300C (* 「 *)
      | 0X300D (* 」 *)
      | 0XFF01 (* ！ *)
      | 0XFF5E (* ～ *)
      | 0XB7 (* · *)
      | 0X2014 (* — *)
      | 0X2026 (* … *) )]
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
    | zh -> T_zh (getch 1)
    | en -> T_eng (getch 1)
    | space -> T_space
    | cr -> T_cr
    | num -> T_num (getch 1)
    | punct -> T_punct (getch 1)
    | dl -> T_dollor
    | ddl -> T_ddollor
    | bt -> T_backtick
    | tbt -> T_tbacktick
    | eof -> T_eof
    | any -> T_other (getch 1)
    | _ -> assert false
  ;;

  let alpha = [%sedlex.regexp? 'A' .. 'Z' | 'a' .. 'z']
  let cmd = [%sedlex.regexp? "\\", Plus alpha]

  let tok_math (lexbuf : Sedlexing.lexbuf) =
    let open Mdtoken.Tokens.MDMath in
    let getch = Sedlexing.lexeme_char lexbuf in
    match%sedlex lexbuf with
    | dl -> T_dollor
    | ddl -> T_ddollor
    | cmd -> T_cmd (getch 1)
    | num -> T_num (getch 1)
    | "{" -> T_lc
    | "}" -> T_rc
    | en_punct -> T_punct (getch 1)
    | eof -> raise @@ Failure "unexpected eof in math mode"
    | any -> T_word (getch 1)
    | _ -> assert false
  ;;

  let tok_code (lexbuf : Sedlexing.lexbuf) =
    let open Mdtoken.Tokens.MDCode in
    let getch = Sedlexing.lexeme_char lexbuf in
    match%sedlex lexbuf with
    | bt -> T_backtick
    | tbt -> T_tbacktick
    | cr -> T_cr
    | space -> T_space (getch 1)
    | eof -> raise @@ Failure "unexpected eof in code mode"
    | any -> T_code (getch 1)
    | _ -> assert false
  ;;
end
