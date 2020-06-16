# vicfred-nim-irc-bot

Bridge bot between irc, telegram and discord.

# Requirements
- nim
- nim irc         `nimble install irc`
- nim telebot     `nimble install telebot`

compile with -d:ssl and -d:release

`nim c -d:ssl -d:release src/bot_irc.nim`


populate .token files
