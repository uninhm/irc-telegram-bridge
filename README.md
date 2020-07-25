# irc-telegram-bridge

Bridge bot between IRC, and Telegram.

## Requirements if you want to compile it
- [nim](https://nim-lang.org)
- nim irc         `nimble install irc`
- nim telebot     `nimble install telebot`

## Compilation

Compile with `-d:ssl` and `-d:release`

`nim c -d:ssl -d:release src/bot_irc.nim`
that uses gcc by default, if you want to use clang:
`nim c --cc:clang -d:ssl -d:release src/bot_irc.nim`

## Usage instructions

Rename the `example_config.ini` file to `config.ini` and set your configs.

Run the binary (Binary and config file must be in the same directory)
