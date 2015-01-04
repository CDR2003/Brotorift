package brotorift

import akka.actor.Actor
import akka.io._
import java.net.InetSocketAddress
import akka.actor.Props
import akka.actor.ActorRef

case class Start(port: Int)

class Service(factory: ConnectionFactory) extends Actor {
  import Tcp._
  
  def receive = {
    case Start(port) =>
      IO(Tcp)(context.system) ! Bind(self, new InetSocketAddress(port))
      context.become(started)
  }
  
  def started: Receive = {
    case CommandFailed(_: Bind) =>
      println("Bind failed")
      context.stop(self)
    case Connected(address, _) =>
      val props = factory.getConnectionProps(sender, address)
      val connection = context.actorOf(props)
      sender ! Register(connection)
  }
}