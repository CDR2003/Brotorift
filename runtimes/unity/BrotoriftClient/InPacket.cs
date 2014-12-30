using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Brotorift
{
	public class InPacket
	{
		public int Header { get; private set; }

		private MemoryStream _stream;

		private BinaryReader _reader;

		public InPacket( MemoryStream stream )
		{
			_stream = stream;
			_reader = new BinaryReader( _stream );
			this.Header = _reader.ReadInt32();
		}

		public T1 Read<T1>( Func<T1> readFunc )
		{
			return readFunc();
		}

		public bool ReadBool()
		{
			return _reader.ReadBoolean();
		}

		public byte ReadByte()
		{
			return _reader.ReadByte();
		}

		public short ReadShort()
		{
			return _reader.ReadInt16();
		}

		public int ReadInt()
		{
			return _reader.ReadInt32();
		}

		public long ReadLong()
		{
			return _reader.ReadInt64();
		}

		public float ReadFloat()
		{
			return _reader.ReadSingle();
		}

		public double ReadDouble()
		{
			return _reader.ReadDouble();
		}

		public string ReadString()
		{
			return _reader.ReadString();
		}

		public byte[] ReadByteBuffer()
		{
			var length = this.ReadInt();
			return _reader.ReadBytes( length );
		}

		public List<T> ReadList<T>( Func<T> readElement )
		{
			var length = this.ReadInt();
			var list = new List<T>( length );
			for( int i = 0; i < length; i++ )
			{
				list.Add( readElement() );
			}
			return list;
		}

		public HashSet<T> ReadSet<T>( Func<T> readElement )
		{
			var length = this.ReadInt();
			var set = new HashSet<T>();
			for( int i = 0; i < length; i++ )
			{
				set.Add( readElement() );
			}
			return set;
		}

		public Dictionary<K, V> ReadMap<K, V>( Func<K> readKey, Func<V> readValue )
		{
			var length = this.ReadInt();
			var map = new Dictionary<K, V>();
			for( int i = 0; i < length; i++ )
			{
				var key = readKey();
				var value = readValue();
				map.Add( key, value );
			}
			return map;
		}

		public T ReadStruct<T>() where T : IStruct, new()
		{
			var value = new T();
			value.ReadFromPacket( this );
			return value;
		}

		public T ReadEnum<T>() where T : struct, IConvertible
		{
			object value = _reader.ReadInt32();
			return (T)value;
		}
	}
}
