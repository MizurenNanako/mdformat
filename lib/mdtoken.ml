module Tokens = struct
  open Sexplib0.Sexp_conv

  type uchar = Uchar.t

  let sexp_of_uchar uch =
    let open Sexplib0.Sexp in
    List [ Atom "unicode"; Atom (uch |> Uchar.to_int |> string_of_int) ]
  ;;

  module MDText = struct
    type token =
      | T_zh of uchar (* 中文字符 *)
      | T_eng of uchar (* 英文字符 *)
      | T_space (* 空白字符 *)
      | T_cr of int (* 换行符 *)
      | T_num of uchar (* 数字 *)
      | T_punct of uchar (* 标点字符 *)
      | T_dollor (* $ 刀乐 *)
      | T_ddollor (* $$ 双刀乐 *)
      | T_backtick (* ` 背踢 *)
      | T_tbacktick (* ``` 三背踢 *)
      (*
         | T_opentag of uchar (* <...> html 开标签 *)
         | T_closetag of uchar (* </...> html 闭标签 *)
         | T_isotag of uchar (* <.../> html 自闭标签 *)
      *)
      | T_other of string (* 其他情况 *)
      | T_eof (* EOF *)
    [@@deriving sexp_of]

    let debug tk = tk |> sexp_of_token |> Sexplib0.Sexp.to_string |> prerr_endline

    let add2buffer buf =
      let a = Buffer.add_utf_8_uchar buf in
      let b = Buffer.add_string buf in
      function
      | T_zh c -> a c
      | T_eng c -> a c
      | T_space -> b " "
      | T_cr n ->
        b "\n";
        String.make n ' ' |> b
      | T_num c -> a c
      | T_punct c -> a c
      | T_dollor -> b "$"
      | T_ddollor -> b "$$"
      | T_backtick -> b "`"
      | T_tbacktick -> b "```"
      | T_other c -> b c
      | T_eof -> ()
    ;;
  end

  module MDMath = struct
    type token =
      | T_dollor (* $ 刀乐 *)
      | T_ddollor (* $$ 双刀乐 *)
      | T_cmd of string (* \... 指令 *)
      | T_num of uchar (* 数字 *)
      | T_word of uchar (* 普通字符（utf8） *)
      | T_lc (* { 开括号 *)
      | T_rc (* } 闭括号 *)
      | T_punct of uchar (* 运算符 *)
      | T_space
      | T_cr of int
    [@@deriving sexp_of]

    let debug tk = tk |> sexp_of_token |> Sexplib0.Sexp.to_string |> prerr_endline

    let add2buffer buf =
      let a = Buffer.add_utf_8_uchar buf in
      let b = Buffer.add_string buf in
      function
      | T_dollor -> b "$"
      | T_ddollor -> b "$$"
      | T_cmd c -> Buffer.add_string buf c
      | T_num c -> a c
      | T_word c -> a c
      | T_lc -> b "{"
      | T_rc -> b "}"
      | T_punct c -> a c
      | T_space -> b " "
      | T_cr n ->
        b "\n";
        String.make n ' ' |> b
    ;;
  end

  module MDCode = struct
    type token =
      | T_backtick (* ` backtick *)
      | T_tbacktick (* ``` triple backtick *)
      | T_cr (* 换行符 *)
      | T_code of uchar (* 普通字符 *)
      | T_space of uchar (* 空白字符 *)
    [@@deriving sexp_of]

    let debug tk = tk |> sexp_of_token |> Sexplib0.Sexp.to_string |> prerr_endline

    let add2buffer buf =
      let a = Buffer.add_utf_8_uchar buf in
      let b = Buffer.add_string buf in
      function
      | T_backtick -> b "`"
      | T_tbacktick -> b "```"
      | T_cr -> b "\n"
      | T_code c -> a c
      | T_space c -> a c
    ;;
  end

  type t =
    | Text of MDText.token
    | Code of MDCode.token
    | Math of MDMath.token
  [@@deriving sexp_of]

  let add2buffer buf = function
    | Text x -> MDText.add2buffer buf x
    | Code x -> MDCode.add2buffer buf x
    | Math x -> MDMath.add2buffer buf x
  ;;

  let debug tk = tk |> sexp_of_t |> Sexplib0.Sexp.to_string |> prerr_endline
end
