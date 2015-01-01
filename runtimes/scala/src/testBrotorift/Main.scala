package testBrotorift

import akka.actor._
import brotorift._

case class Register(connection: ActorRef, info: UserInfo)
case class Login(connection: ActorRef, info: UserInfo)

class UserCenter extends Actor {
  private val users = scala.collection.immutable.Map[String, UserInfo]()
  
  def receive = {
    case Register(connection, info) =>
      val user = users.get(info.username)
      if (user.isDefined) {
        connection ! ChatClientConnection.RespondRegister(RegisterResult.DuplicateUsername)
      } else {
        connection ! ChatClientConnection.RespondRegister(RegisterResult.Succeeded)
      }
    case Login(connection, info) =>
      println("Attempt to login using: " + info.username + ", " + info.password)
      val user = users.get(info.username)
      if (user.isDefined) {
        if (user.get.password == info.password) {
          connection ! ChatClientConnection.RespondLogin(LoginResult.Succeeded)
        } else {
          connection ! ChatClientConnection.RespondLogin(LoginResult.InvalidPassword)
        }
      } else {
        connection ! ChatClientConnection.RespondLogin(LoginResult.InvalidUsername)
      }
  }
}


class MyHandler(userCenter: ActorRef) extends ChatClientConnection.Handler {
  /** Triggers when the connection opened
   * 
   *  @param connection The incoming connection
   */
  def onOpen(connection: ActorRef) = {
    println("Opened")
  }
  
  /** Triggers when the connection closed
   *  
   *  @param connection The closed connection
   */
  def onClose(connection: ActorRef) = {
    println("Closed")
  }
  
  /** 请求登录
   *  
   *  @param connection The message sender
   *  @param info 登录时填写的用户信息
   */
  def requestLogin(connection: ActorRef, info: UserInfo) = {
    userCenter ! Login(connection, info)
  }
  
  /** 请求注册
   *  
   *  @param connection The message sender
   *  @param info 注册时填写的用户信息
   */
  def requestRegister(connection: ActorRef, info: UserInfo) = {
    userCenter ! Register(connection, info)
  }
}


object Main extends App {
  val system = ActorSystem("chat")
  val userCenter = system.actorOf(Props[UserCenter], "userCenter")
  val service = system.actorOf(Props(classOf[ChatClientService], new MyHandler(userCenter)), "chatService")
  service ! Start(9000)
}