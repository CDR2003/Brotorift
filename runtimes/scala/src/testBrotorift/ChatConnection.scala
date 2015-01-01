package testBrotorift

import brotorift.Connection
import akka.actor.ActorRef
import java.net.InetSocketAddress
import brotorift.OutPacket
import brotorift.InPacket
import brotorift.Struct
import akka.io.Tcp.ConnectionClosed

object Weekdays extends Enumeration {
  type Weekdays = Value
  val Monday = Value(0)
  val Tuesday = Value(1)
}

class UserInfo extends Struct {
  var username: String = _
  var password: String = _
  
  override def readFromPacket(packet: InPacket) = {
    username = packet.readString()
    password = packet.readString()
  }
  
  override def writeToPacket(packet: OutPacket) = {
    packet.writeString(username)
    packet.writeString(password)
  }
}

object ChatConnection {
  private object InMessage {
    val SetName = 1001
    val SetWeekday = 1002
  }
  
  private object OutMessage {
    val SetNameResult = 2001
  }
  
  trait Handler {
    def onOpen(connection: ActorRef)
    def onClose(connection: ActorRef)
    def setName(connection: ActorRef, name: String)
  }
  
  case class SetNameResult(result: Boolean)
}

class ChatConnection(remote: ActorRef, address: InetSocketAddress, handler: ChatConnection.Handler) extends Connection(remote, address) {
  import ChatConnection._
  
  handler.onOpen(self)
  
  def processMessages: Receive = {
    case _: ConnectionClosed =>
      handler.onClose(self)
      context.stop(self)
    case SetNameResult(result) =>
      val packet = new OutPacket(OutMessage.SetNameResult)
      packet.writeBool(result)
      this.sendPacket(packet)
  }
  
  def processPacket(packet: InPacket) = {
    packet.header match {
      case InMessage.SetName =>
        val name = packet.readString()
        handler.setName(self, name)
    }
  }
}