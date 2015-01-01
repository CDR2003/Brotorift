package testBrotorift

import brotorift._
import java.net.InetSocketAddress
import akka.actor.Props
import akka.actor.ActorRef
import akka.io.Tcp.ConnectionClosed

/** Weekdays of the whole week */
object Weekdays extends Enumeration {
  
  /** The first day */
  val Monday = Value(1)
  
  /** The second day */
  val Tuesday = Value(200)
}

/** The user info */
class UserInfo extends Struct {
  
  /** The username */
  var username: String = _
  
  /** The password */
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

class ChatService(handler: ChatConnection.Handler) extends Service {
  override def createConnection(remote: ActorRef, address: InetSocketAddress) = {
    context.actorOf(Props(classOf[ChatConnection], remote, address, handler))
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
    
    /** Triggers when the connection opened
     * 
     *  @param connection The incoming connection
     */
    def onOpen(connection: ActorRef)
    
    /** Triggers when the connection closed
     *  
     *  @param connection The closed connection
     */
    def onClose(connection: ActorRef)
    
    /** Set the username
     *  
     *  @param connection The connection
     *  @param name The username
     */
    def setName(connection: ActorRef, name: String)
  }
  
  /** Set the name result
   *  
   *  @param result the setName result
   */
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