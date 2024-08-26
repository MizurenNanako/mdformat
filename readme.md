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