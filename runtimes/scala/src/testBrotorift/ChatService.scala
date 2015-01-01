package testBrotorift

import brotorift.Service
import java.net.InetSocketAddress
import akka.actor.Props
import akka.actor.ActorRef

class ChatService(handler: ChatConnection.Handler) extends Service {
  override def createConnection(remote: ActorRef, address: InetSocketAddress) = {
    context.actorOf(Props(classOf[ChatConnection], remote, address, handler))
  }
}