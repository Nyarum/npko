import patty, macros

type
    IncomePacket = object of RootObj

    Auth * = object of IncomePacket

type
    OutcomePacket = object of RootObj

    FirstDate * = object of OutcomePacket
        date *: string

    Chars * = object of OutcomePacket

macro unifiedPack(procName: string): untyped =
    result = quote do:
        proc `procName`(packets: seq[OutcomePacket]) =
            for pkt in packets:
                case pkt of `OutcomePacket`:
                    echo "Generic OutcomePacket (fallback)"
                else:
                    discard  # Avoid match error for unsupported types
      echo "Finished packing"

  let casesNode = result[0][1][0][2][1] # Access the "case pkt of" node

  for typ in bindSym("OutcomePacket").symbol.typeInst.typeDesc.fields:
    let caseNode = quote do:
      `typ.name`:
        pack(cast[`typ.name`](pkt))
    casesNode.add caseNode

proc pack *(packet: Chars) =
    echo "pack chars"

proc pack *(packets: seq[OutcomePacket]) =
    for pkt in packets:
        echo typeof(pkt)
        when pkt is Chars:
            pack(pkt)

    echo "pack"

proc route *(packet: FirstDate): seq[OutcomePacket] =
    echo "test"
    return cast[seq[OutcomePacket]](@[Chars()])