package brotorift

import akka.util.ByteString

object TestPacket extends App {
  val packet = new InPacket(ByteString())
}