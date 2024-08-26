module Tokens = struct
  module MDText = struct
    type token =
      | T_zh of Uchar.t (* 中文字符 *)
      | T_eng of Uchar.t (* 英文字符 *)
      | T_space (* 空白字符 *)
      | T_cr (* 换行符 *)
      | T_num of Uchar.t (* 数字 *)
      | T_punct of Uchar.t (* 标点字符 *)
      | T_dollor (* $ 刀乐 *)
      | T_ddollor (* $$ 双刀乐 *)
      | T_backtick (* ` 背踢 *)
      | T_tbacktick (* ``` 三背踢 *)
      (*
         | T_opentag of Uchar.t (* <...> html 开标签 *)
         | T_closetag of Uchar.t (* </...> html 闭标签 *)
         | T_isotag of Uchar.t (* <.../> html 自闭标签 *)
      *)
      | T_other of string (* 其他情况 *)
      | T_eof (* EOF *)

    let add2buffer buf =
      let a = Buffer.add_utf_8_uchar buf in
      let b = Buffer.add_string buf in
      function
      | T_zh c -> a c
      | T_eng c -> a c
      | T_space -> b " "
      | T_cr -> b "\n"
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
      | T_num of Uchar.t (* 数字 *)
      | T_word of Uchar.t (* 普通字符（utf8） *)
      | T_lc (* { 开括号 *)
      | T_rc (* } 闭括号 *)
      | T_punct of Uchar.t (* 运算符 *)
      | T_space
      | T_cr

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
      | T_cr -> b "\n"
    ;;
  end

  module MDCode = struct
    type token =
      | T_backtick (* ` backtick *)
      | T_tbacktick (* ``` triple backtick *)
      | T_cr (* 换行符 *)
      | T_code of Uchar.t (* 普通字符 *)
      | T_space of Uchar.t (* 空白字符 *)

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
  
  let add2buffer buf = function
  | Text x -> MDText.add2buffer buf x
  | Code x -> MDCode.add2buffer buf x
  | Math x -> MDMath.add2buffer buf x
end
