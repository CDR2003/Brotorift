package brotorift

import akka.actor.Actor
import akka.io._
import java.net.InetSocketAddress

case class Start(port: Int)

class Server extends Actor {
  import Tcp._
  
  def receive = {
    case Start(port) =>
      IO(Tcp)(context.system) ! Bind(self, new InetSocketAddress(port))
      context become started
  }
  
  def started: Receive = {
    case CommandFailed(_: Bind) =>
      
  }
}