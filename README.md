# Brotorift

## Types

### Base types

* Bool: byte(1)
* Byte: byte(1)
* Short: byte(2)
* Int: byte(4)
* Long: byte(8)
* Float: byte(4)
* Double: byte(8)
* String: byte(1) + byte(len)
* ByteBuffer: byte(1) + byte(len)
* List<T>: byte(4) + byte(T) * len
* Set<T>: byte(4) + byte(T) * len
* Map<K, V>: byte(4) + (byte(K) + byte(V)) * len
* Vector2: byte(Float) * 2
* Vector3: byte(Float) * 3
* Matrix4: byte(Float) * 16

### User defined types

* Enum
* Struct