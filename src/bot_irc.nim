# ------ Constants ------

const TG_GROUP_ID = -1001452904118
const IRC = "irc.twitch.tv"
const IRC_NICK = "NICK" # Doesn't work on twitch but must not be empty
const IRC_CHANNEL = "#vicfred"


# ------ Only edit if you know that you do ------

import irc, strutils, telebot, strformat, asyncdispatch, options

let TELEGRAM_TOKEN = readFile("telegram.token").strip
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
      if "hola" in msg.normalize:
        await client.privmsg(event.origin, fmt"Hola {event.nick}!")
      elif msg == "!lag":
        await client.privmsg(event.origin, formatFloat(client.getLag))
      if msg == "!users":
        await client.privmsg(event.origin, "Users: " &
            client.getUserList(event.origin).join("A-A"))
      let text = fmt"*{event.nick}*: {msg}"
      discard await bot.sendMessage(TG_GROUP_ID, text, parseMode = "markdown")

var client {.threadvar.}: AsyncIrc
client = newAsyncIrc(IRC, nick = IRC_NICK,
                      joinChans = @[IRC_CHANNEL],
                      serverPass = readFile("irc.pass"),
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
