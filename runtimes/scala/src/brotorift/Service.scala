package brotorift

import akka.actor.Actor
import akka.io._
import java.net.InetSocketAddress
import akka.actor.Props
import akka.actor.ActorRef

case class Start(port: Int)

abstract class Service extends Actor {
  import Tcp._
  
  val connections = scala.collection.mutable.Map[ActorRef, ActorRef]()
  
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
      val connection = this.createConnection(sender, address)
      connections += sender -> connection
      sender ! Register(connection)
    case _: ConnectionClosed =>
      val connection = connections.get(sender)
      if (connection.isDefined) {
        connection.get ! Connection.OnClose()
      }
  }
  
  def createConnection(remote: ActorRef, address: InetSocketAddress): ActorRef
}