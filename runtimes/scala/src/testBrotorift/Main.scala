package testBrotorift

import akka.actor._
import brotorift._

class Handler extends ChatConnection.Handler {
  override def onOpen(connection: ActorRef) {
    println("OnOpen")
  }
  
  override def onClose(connection: ActorRef) {
    println("OnClose")
  }
  
  override def setName(connection: ActorRef, name: String) {
    println(s"Name set to $name")
    connection ! ChatConnection.SetNameResult(true)
  }
}

object Main extends App {
  println(Weekdays.Tuesday.id)
  
  val system = ActorSystem("chat")
  val service = system.actorOf(Props(classOf[ChatService], new Handler), "chatService")
  service ! Start(9000)
}