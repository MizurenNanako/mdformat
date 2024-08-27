# `mdformat` is a markdown pangu and depangu formatter

## What is this?

### `mdformat` is a pangu formatter for Chinese charactors

It inserts space between Chinese and non-Chinese non-punctuation charactors.

It also eliminates tailing spaces and combine multiple spaces into one.

### `mdformat` is a depangu formatter for Math mode

It removes all unnecessary spaces of math code, but indentions will be preserved.

## What do it do?

It reads markdown from `stdin` and outputs formatted markdown to `stdout` once `EOF` is reached if the input is legal, otherwise nothing will be outputed and an error will be reported via `stderr`.

## How to compile it?

### With `dune` build system

Just `dune build` it, binary executable will be produced in `./_build/install/default/bin/mdformat`.

You can copy it into your favored directory or some where executable:

```sh
install ./_build/install/default/bin/mdformat /usr/bin/mdformat 
```

## Example

### Input

**第一组Group1**

```markdown
1-不定积分1-16

我I喜do欢love你you。这里是     空格。

`我I喜do欢love你you。这里是     空格。`

$$
\int\dfrac{1}{x^{2}\left(1+x^{2}\right)}\mathrm{d}x
$$

使 $\dfrac A { x ^ { 2 } } + \dfrac { B } { 1 + x ^ { 2 } } = \dfrac { 1 } { x ^ { 2 } \left ( 1 + x ^ { 2 } \right ) } $，待定系数：

$$
\begin{cases}
    \Gamma_1:&
    \begin{cases}
        y   y' & = f(x) \\
        y + y' & = g(x) \\
    \end{cases} \\
    \Gamma_2:&
    \begin{cases}
        \ln y   \ln (y') & = f(x) \\
        \ln y + \ln (y') & = g(x) \\
    \end{cases} \\
\end{cases}
$$
```

1-不定积分1-16

我I喜do欢love你you。这里是     空格。

`我I喜do欢love你you。这里是     空格。`

$$
\int\dfrac{1}{x^{2}\left(1+x^{2}\right)}\mathrm{d}x
$$

使 $\dfrac A { x ^ { 2 } } + \dfrac { B } { 1 + x ^ { 2 } } = \dfrac { 1 } { x ^ { 2 } \left ( 1 + x ^ { 2 } \right ) } $，待定系数：

$$
\begin{cases}
    \Gamma_1:&
    \begin{cases}
        y   y' & = f(x) \\
        y + y' & = g(x) \\
    \end{cases} \\
    \Gamma_2:&
    \begin{cases}
        \ln y   \ln (y') & = f(x) \\
        \ln y + \ln (y') & = g(x) \\
    \end{cases} \\
\end{cases}
$$

### Command

```sh
cat readme.md | dune exec mdformat | diff readme.md -
```

#### Output

```text
35c35
< **第一组Group1**
---
> **第一组 Group1**
66c66
< 1-不定积分1-16
---
> 1-不定积分 1-16
68c68
< 我I喜do欢love你you。这里是     空格。
---
> 我 I 喜 do 欢 love 你 you。这里是 空格。
76c76
< 使 $\dfrac A { x ^ { 2 } } + \dfrac { B } { 1 + x ^ { 2 } } = \dfrac { 1 } { x ^ { 2 } \left ( 1 + x ^ { 2 } \right ) } $，待定系数：
---
> 使 $\dfrac A{x^{2}}+\dfrac{B}{1+x^{2}}=\dfrac{1}{x^{2}\left (1+x^{2}\right )}$，待定系数：
82,84c82,84
<         y   y' & = f(x) \\
<         y + y' & = g(x) \\
<     \end{cases} \\
---
>         yy'&=f(x)\\
>         y+y'&=g(x)\\
>     \end{cases}\\
87,89c87,89
<         \ln y   \ln (y') & = f(x) \\
<         \ln y + \ln (y') & = g(x) \\
<     \end{cases} \\
---
>         \ln y\ln (y')&=f(x)\\
>         \ln y+\ln (y')&=g(x)\\
>     \end{cases}\\

```