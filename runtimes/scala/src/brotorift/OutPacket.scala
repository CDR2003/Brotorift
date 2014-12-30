package brotorift

import java.nio.ByteOrder

class OutPacket {
  implicit val byteOrder = ByteOrder.LITTLE_ENDIAN
  
  def write(value: Boolean) = {
  }
  
  def write[T](list: List[T]): Unit = {
    //this.write(list.head)
  }
}