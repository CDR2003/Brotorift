package testBrotorift

import akka.actor._
import brotorift._

class Handler extends ChatConnection.Handler {
  override def onOpen(connection: ActorRef) {
    
  }
  
  override def onClose(connection: ActorRef) {
    
  }
  
  override def setName(connection: ActorRef, name: String) {
    connection ! ChatConnection.SetNameResult(true)
  }
}

object Main extends App {
  val system = ActorSystem("chat")
  val service = system.actorOf(Props(classOf[ChatService], new Handler), "chatService")
  service ! Start(9000)
}