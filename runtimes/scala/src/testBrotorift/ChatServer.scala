package testBrotorift

import brotorift._
import java.net.InetSocketAddress
import akka.actor.Props
import akka.actor.ActorRef
import akka.io.Tcp.ConnectionClosed


/** 登录结果 */
object LoginResult extends Enumeration {
  
  /** 成功 */
  val Succeeded = Value(0)

  /** 用户名不存在 */
  val InvalidUsername = Value(1)

  /** 密码错误 */
  val InvalidPassword = Value(2)
}

/** 注册结果 */
object RegisterResult extends Enumeration {
  
  /** 成功 */
  val Succeeded = Value(0)

  /** 重复用户名已存在 */
  val DuplicateUsername = Value(1)
}


/** 用户信息 */
class UserInfo extends Struct {
  
  /** 用户名 */
  var username: String = _
  
  /** 密码 */
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


class ChatClientService(handler: ChatClientConnection.Handler) extends Service {
  override def createConnection(remote: ActorRef, address: InetSocketAddress) = {
    context.actorOf(Props(classOf[ChatClientConnection], remote, address, handler))
  }
}


object ChatClientConnection {
  private object InMessage {
    val RequestLogin = 1001
    val RequestRegister = 1002
  }
  
  private object OutMessage {
    val RespondLogin = 2001
    val RespondRegister = 2002
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
    
    /** 请求登录
     *  
     *  @param connection The message sender
     *  @param info 登录时填写的用户信息
     */
    def requestLogin(connection: ActorRef, info: UserInfo)
    /** 请求注册
     *  
     *  @param connection The message sender
     *  @param info 注册时填写的用户信息
     */
    def requestRegister(connection: ActorRef, info: UserInfo)
  }
  
  /** 回复登录请求
   *  
   *  @param result 登录结果
   */
  case class RespondLogin(result: LoginResult.Value)

  /** 回复注册请求
   *  
   *  @param result 注册结果
   */
  case class RespondRegister(result: RegisterResult.Value)
}


class ChatClientConnection(remote: ActorRef, address: InetSocketAddress, handler: ChatClientConnection.Handler) extends Connection(remote, address) {
  import ChatClientConnection._
  
  handler.onOpen(self)
  
  def processMessages: Receive = {
    case _: ConnectionClosed =>
      handler.onClose(self)
      context.stop(self)
    case RespondLogin(result) =>
      val packet = new OutPacket(OutMessage.RespondLogin)
      packet.writeInt(result.id)
      this.sendPacket(packet)
    case RespondRegister(result) =>
      val packet = new OutPacket(OutMessage.RespondRegister)
      packet.writeInt(result.id)
      this.sendPacket(packet)
  }
  
  def processPacket(packet: InPacket) = {
    packet.header match {
      case InMessage.RequestLogin =>
        val info = packet.readStruct(new UserInfo)
        handler.requestLogin(self, info)
      case InMessage.RequestRegister =>
        val info = packet.readStruct(new UserInfo)
        handler.requestRegister(self, info)
    }
  }
}
