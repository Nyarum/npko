import  strformat, strutils, net, asyncdispatch, asyncnet, streams
import ./routes

proc handleClient(client: AsyncSocket) {.async.} =
  defer:
    client.close()
    echo "Client disconnected."
    
  echo "Client connected: ", client.getPeerAddr()

  await client.send(
    16.pack(getFirstDate().pack)
  )

  while not client.isClosed:
    try:
      let buf = await client.recv(1024)
      echo buf.len
      if buf.len == 0:
        break  # Client disconnected



      let data = buf.strip()
      echo "Received from client: ", data
      #await client.send("You said: " & data)  # Echo back the data
    except OSError:
      echo "os error"
      break  # Handle client disconnection or errors

proc startServer(port: Port) {.async.} =
  var server = newAsyncSocket(buffered=false)
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(port)
  echo fmt"Started tcp server... {port}"
  server.listen()

  while true:
    try:
      let client = await server.accept()
      echo "..Got connection "

      asyncCheck handleClient(client)
    except:
      echo "closed server"
      break

when isMainModule:
  asyncCheck startServer(1973.Port)
  runForever()
