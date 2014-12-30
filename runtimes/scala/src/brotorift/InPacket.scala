package brotorift

import akka.util.ByteString
import java.nio.ByteOrder
import scala.collection.mutable.ListBuffer
import scala.collection.mutable.Set
import scala.reflect.api._
import scala.reflect.runtime.universe._
import akka.util.ByteIterator

object InPacket {
  trait Reader[T] {
    def readOne(packet: InPacket): T
  }
  
  implicit val byteOrder = ByteOrder.LITTLE_ENDIAN
  
  implicit object BooleanReader extends Reader[Boolean] {
    def readOne(packet: InPacket): Boolean = {
      packet.iterator.getByte != 0
    }
  }
  
  implicit object ByteReader extends Reader[Byte] {
    def readOne(packet: InPacket): Byte = {
      packet.iterator.getByte
    }
  }
  
  implicit def ListReader[T: Reader] = new Reader[List[T]] {
    def readOne(packet: InPacket): List[T] = {
      val len = packet.iterator.getInt
      val listBuffer = new ListBuffer[T]()
      for (i <- 1 to len) {
        listBuffer += packet.read[T]
      }
      listBuffer.toList
    }
  }
}

class InPacket(val buffer: ByteString) {
  import InPacket._
  
  implicit val byteOrder = ByteOrder.LITTLE_ENDIAN
  
  private val iterator = buffer.iterator
  
  val header = iterator.getInt
  
  def read[T](implicit e: Reader[T]): T = {
    e.readOne(this)
  }
  
  def readBoolean() = {
    this.read[Boolean]
  }
  
  def readByte() = {
    this.read[Byte]
  }
  
  def readList[T: Reader]() = {
    this.read[List[T]]
  }
}