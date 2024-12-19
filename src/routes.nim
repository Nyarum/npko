import patty, macros, times, strformat, streams, endians

type
    Header* = object
        len: uint16
        id: uint32
        opcode: uint16
        data: string

type
    IncomePacket = object of RootObj

    Auth* = object of IncomePacket

type
    OutcomePacket = object of RootObj

    FirstDate* = object of OutcomePacket
        date*: string

    Chars* = object of OutcomePacket

proc getFirstDate*(): FirstDate =
  let timeNow = now()
  let milliseconds = timeNow.nanosecond div 1_000_000
  let formatedTime = timeNow.format("MM-dd HH:mm:ss")
  return FirstDate(date: fmt"{formatedTime}:{milliseconds:03}")

proc write*[T](s: Stream, x: T, swapEndian: bool) =
  ## Generic write procedure. Writes `x` to the stream `s` after converting to big-endian format.
  ## Implementation swaps endianness before writing to ensure consistent cross-platform representation.
  var temp: T = x
  when sizeof(T) == 2:
    swapEndian16(addr temp, addr x)
  elif sizeof(T) == 4:
    swapEndian32(addr temp, addr x)
  elif sizeof(T) == 8:
    swapEndian64(addr temp, addr x)
  else:
    # For types that don't need endian conversion or unsupported sizes
    temp = x
    
  writeData(s, addr temp, sizeof(T))

proc pack*(opcode: uint16, packet: string): string =
    var stream = newStringStream()
    stream.write(packet.len.uint16 + 6.uint16, true)
    stream.write(80.uint32)
    stream.write(opcode, true)
    stream.write(packet)
    return stream.data

proc pack*(packet: FirstDate): string =
    var stream = newStringStream()
    stream.write(packet.date)
    return stream.data

proc pack*(packet: Chars): string =
    echo "pack chars"

proc pack*(packets: seq[OutcomePacket]) =
    for pkt in packets:
        echo typeof(pkt)
        when pkt is Chars:
            pack(pkt)

    echo "pack"

proc route*(packet: Auth): seq[string] =
    echo "test"
    
    return @[Chars().pack]
    