# vicfred-nim-irc-bot

Bridge bot between irc, telegram and discord.

# Requirements
- nim
- nim irc         `nimble install irc`
- nim telebot     `nimble install telebot`

# Installation instructions

compile with -d:ssl and -d:release

`nim c -d:ssl -d:release src/bot_irc.nim`


populate telegram.token and twitch.token files

copy the binary and .token files

`scp telegram.twitch twitch.token src/bot_irc host:`
