package brotorift

import akka.util.ByteString
import java.nio.ByteOrder
import scala.collection.mutable.ListBuffer
import scala.collection.mutable.Set
import scala.reflect.api._
import scala.reflect.runtime.universe._
import akka.util.ByteIterator
import scala.collection.mutable.Map


class InPacket(val buffer: ByteString) {
  implicit val byteOrder = ByteOrder.LITTLE_ENDIAN
  
  private val iterator = buffer.iterator
  val header = iterator.getInt
  
  def readBool() = {
    iterator.getByte != 0
  }
  
  def readByte() = {
    iterator.getByte
  }
  
  def readShort() = {
    iterator.getShort
  }
  
  def readInt() = {
    iterator.getInt
  }
  
  def readLong() = {
    iterator.getLong
  }
  
  def readFloat() = {
    iterator.getFloat
  }
  
  def readDouble() = {
    iterator.getDouble
  }
  
  def readString() = {
    val buffer = this.readByteBuffer()
    buffer.utf8String
  }
  
  def readByteBuffer() = {
    val length = this.readInt()
    val bytes = new Array[Byte](length)
    iterator.getBytes(bytes)
    ByteString(bytes)
  }
  
  def readList[T](readElement: Function0[T]) = {
    val length = this.readInt()
    val list = new ListBuffer[T]()
    for (i <- 1 to length) {
      list += readElement()
    }
    list.toList
  }
  
  def readSet[T](readElement: Function0[T]) = {
    val length = this.readInt()
    val set = Set[T]()
    for (i <- 1 to length) {
      set += readElement()
    }
    set.toSet
  }
  
  def readMap[K, V](readKey: Function0[K], readValue: Function0[V]) = {
    val length = this.readInt()
    val map = Map[K, V]()
    for (i <- 1 to length) {
      val key = readKey()
      val value = readValue()
      map += key -> value
    }
    map.toMap
  }
  
  def readStruct[T <: Struct](obj: T) = {
    obj.readFromPacket(this)
    obj
  }
}