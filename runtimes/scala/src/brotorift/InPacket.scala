package brotorift

import akka.util.ByteString
import java.nio.ByteOrder
import scala.collection.mutable.ListBuffer
import scala.collection.mutable.Set
import scala.reflect.api._
import scala.reflect.runtime.universe._
import akka.util.ByteIterator


class InPacket(val buffer: ByteString) {
  implicit val byteOrder = ByteOrder.LITTLE_ENDIAN
  
  private val iterator = buffer.iterator
  
  val header = iterator.getInt
}