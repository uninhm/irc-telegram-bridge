import irc, strutils, telebot, strformat, asyncdispatch, options, parsecfg

# ------ Config ------

let config         = loadConfig("config.ini")

var
  TELEGRAM_TOKEN {.threadvar.}: string
  IRC            {.threadvar.}: string
  IRC_NICK       {.threadvar.}: string
  IRC_CHANNEL    {.threadvar.}: string
  IRC_PASS       {.threadvar.}: string
  TG_GROUP_ID    {.threadvar.}: int

TG_GROUP_ID    = config.getSectionValue("Telegram", "group_id").parseInt
TELEGRAM_TOKEN = config.getSectionValue("Telegram", "token")

IRC            = config.getSectionValue("IRC", "irc")
IRC_NICK       = config.getSectionValue("IRC", "nick")
IRC_CHANNEL    = config.getSectionValue("IRC", "channel")
IRC_PASS       = config.getSectionValue("IRC", "pass")


# ------ Code ------

var bot {.threadvar.}: TeleBot
bot = newTeleBot(TELEGRAM_TOKEN)


proc onIrcEvent(client: AsyncIrc, event: IrcEvent) {.async.} =
  case event.typ
  of EvConnected:
    discard nil
  of EvDisconnected, EvTimeout:
    await client.reconnect()
  of EvMsg:
    if event.cmd == MPrivMsg:
      var msg = event.params[event.params.high]
      let text = fmt"*{event.nick}*: {msg}"
      discard await bot.sendMessage(TG_GROUP_ID, text, parseMode = "markdown")

var client {.threadvar.}: AsyncIrc
client = newAsyncIrc(IRC, nick = IRC_NICK,
                      joinChans = @[IRC_CHANNEL],
                      serverPass = IRC_PASS,
                      callback = onIrcEvent)

proc updateHandler(b: Telebot, u: Update): Future[bool] {.async.} =
  if not u.message:
    return true
  var m = u.message.get
  if m.text and m.chat.id == TG_GROUP_ID:
    await client.privmsg(IRC_CHANNEL,
          fmt"{m.fromUser.get.firstName}: {m.text.get}")


bot.onUpdate(updateHandler)

asyncCheck client.run()
discard bot.pollAsync()
runForever()
