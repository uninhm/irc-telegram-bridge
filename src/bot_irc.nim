import irc, strutils, telebot, strformat, asyncdispatch, options

let TELEGRAM_TOKEN = readFile("telegram.token").strip
var bot {.threadvar.}: TeleBot
bot = newTeleBot(TELEGRAM_TOKEN)

const GROUP_ID = -1001452904118

proc onIrcEvent(client: AsyncIrc, event: IrcEvent) {.async.} =
  case event.typ
  of EvConnected:
    discard nil
  of EvDisconnected, EvTimeout:
    await client.reconnect()
  of EvMsg:
    if event.cmd == MPrivMsg:
      var msg = event.params[event.params.high]
      if msg == "!test":
        await client.privmsg(event.origin, "hello")
      elif "hola" in msg.normalize:
        await client.privmsg(event.origin, fmt"Hola {event.nick}!")
      elif msg == "!lag":
        await client.privmsg(event.origin, formatFloat(client.getLag))
      if msg == "!users":
        await client.privmsg(event.origin, "Users: " &
            client.getUserList(event.origin).join("A-A"))
      let text = fmt"{event.nick}: {msg}"
      discard await bot.sendMessage(GROUP_ID, text)
      echo text

var client {.threadvar.}: AsyncIrc
client = newAsyncIrc("irc.twitch.tv", nick="nimbridgebot",
                      joinChans = @["#vicfred"],
                      serverPass = readFile("twitch.token"),
                      callback = onIrcEvent)

proc updateHandler(b: Telebot, u: Update): Future[bool] {.async.} =
  if not u.message:
    return true
  var m = u.message.get
  if m.text:
    await client.privmsg("#vicfred", fmt"{m.fromUser.get.firstName}: {m.text.get}")


bot.onUpdate(updateHandler)

asyncCheck client.run()
discard bot.pollAsync()
runForever()
