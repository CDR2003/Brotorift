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
  
  def this(username: String, password: String) = {
    this()
    this.username = username
    this.password = password
  }

  override def readFromPacket(packet: InPacket) = {
    username = packet.readString()
    password = packet.readString()
  }
  
  override def writeToPacket(packet: OutPacket) = {
    packet.writeString(username)
    packet.writeString(password)
  }
}


object ChatClientConnectionBase {
  private object InMessage {
    val RequestLogin = 1001
    val RequestRegister = 1002
  }
  
  private object OutMessage {
    val RespondLogin = 2001
    val RespondRegister = 2002
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


abstract class ChatClientConnectionBase(remote: ActorRef, address: InetSocketAddress) extends Connection(remote, address) {
  import ChatClientConnectionBase._
  
  this.onOpen()
  
  override def processMessages(msg: Any): Unit = {
    msg match {
      case _: ConnectionClosed =>
        this.onClose()
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
  }
  
  def processPacket(packet: InPacket) = {
    packet.header match {
      case InMessage.RequestLogin =>
        val info = packet.readStruct(new UserInfo)
        this.requestLogin(info)
      case InMessage.RequestRegister =>
        val info = packet.readStruct(new UserInfo)
        this.requestRegister(info)
    }
  }

  /** Triggers when the connection opened
   * 
   */
  def onOpen()
  
  /** Triggers when the connection closed
   *  
   */
  def onClose()
  
  /** 请求登录
   *  
   *  @param connection The message sender
   *  @param info 登录时填写的用户信息
   */
  def requestLogin(info: UserInfo)

  /** 请求注册
   *  
   *  @param connection The message sender
   *  @param info 注册时填写的用户信息
   */
  def requestRegister(info: UserInfo)
}
