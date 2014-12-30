package brotorift

trait Struct {
  def readFromPacket(packet: InPacket): Unit
  def writeToPacket(packet: OutPacket): Unit
}