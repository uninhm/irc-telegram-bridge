import irc, strutils
var client = newIrc("irc.twitch.tv", nick="TestBotVicfred",
                 joinChans = @["#vicfred"], serverPass = readFile("secret.ket"))
client.connect()
while true:
  var event: IrcEvent
  if client.poll(event):
    case event.typ
    of EvConnected:
      discard
    of EvDisconnected, EvTimeout:
      break
    of EvMsg:
      if event.cmd == MPrivMsg:
        var msg = event.params[event.params.high]
        if msg == "!test":
          client.privmsg(event.origin, "hello")
        elif "hola" in msg.normalize:
          client.privmsg(event.origin, "Hola $1!" % @[event.nick])
        elif msg == "!lag":
          client.privmsg(event.origin, formatFloat(client.getLag))
        echo msg
