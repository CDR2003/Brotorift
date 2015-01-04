package brotorift

import akka.actor.Actor
import akka.actor.ActorRef
import java.net.InetSocketAddress
import akka.io.Tcp.Received
import akka.util.ByteString
import akka.util.ByteStringBuilder
import java.nio.ByteOrder
import akka.io.Tcp.Write
import akka.io.Tcp.ConnectionClosed

object Connection {
  val IntSize = 4
}

abstract class Connection(remote: ActorRef, address: InetSocketAddress) extends Actor {
  import Connection._
  
  implicit val byteOrder = ByteOrder.LITTLE_ENDIAN
  
  private var buffer = ByteString()
  
  def receive = {
    case Received(data) =>
      this.processData(data)
    case other =>
      this.processMessages(other)
  }
  
  def processData(data: ByteString): Unit = {
    buffer ++= data
    
    while (buffer.length > IntSize) {
      val iterator = buffer.iterator
      val packetSize = iterator.getInt
      if (buffer.length - IntSize < packetSize) {
        return
      }
      
      val content = new Array[Byte](packetSize)
      iterator.getBytes(content)
      this.processPacket(new InPacket(ByteString(content)))
      
      buffer = buffer.drop(IntSize + packetSize)
    }
  }
  
  protected def sendPacket(packet: OutPacket) = {
    val bsb = new ByteStringBuilder()
    bsb.putInt(packet.length)
    
    val buffer = packet.buffer.toArray
    bsb.putBytes(buffer)
    
    remote ! Write(bsb.result)
  }
  
  def processMessages(msg: Any): Unit
  def processPacket(packet: InPacket): Unit
}