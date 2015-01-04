package brotorift

import akka.actor.ActorRef
import java.net.InetSocketAddress
import akka.actor.Props

trait ConnectionFactory {
  def getConnectionProps(remote: ActorRef, address: InetSocketAddress): Props
}