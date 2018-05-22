using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;

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

		public ushort ReadUShort()
		{
			return _reader.ReadUInt16();
		}

		public uint ReadUInt()
		{
			return _reader.ReadUInt32();
		}

		public ulong ReadULong()
		{
			return _reader.ReadUInt64();
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
			var buffer = this.ReadByteBuffer();
			return Encoding.UTF8.GetString( buffer );
		}

		public DateTime ReadDateTime()
		{
			var timestamp = this.ReadInt();
			return timestamp.ToDateTime();
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

		public T ReadStruct<T>( T obj ) where T : IStruct
		{
			obj.ReadFromPacket( this );
			return obj;
		}

		public Vector2 ReadVector2()
		{
			var x = this.ReadFloat();
			var y = this.ReadFloat();
			return new Vector2( x, y );
		}

		public Vector3 ReadVector3()
		{
			var x = this.ReadFloat();
			var y = this.ReadFloat();
			var z = this.ReadFloat();
			return new Vector3( x, y, z );
		}

		public Color ReadColor()
		{
			var r = this.ReadFloat();
			var g = this.ReadFloat();
			var b = this.ReadFloat();
			var a = this.ReadFloat();
			return new Color( r, g, b, a );
		}
	}
}
