using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Brotorift
{
	public class Packet
	{
		public int Header { get; private set; }

		public byte[] Buffer
		{
			get
			{
				return _stream.GetBuffer();
			}
		}

		public int Length
		{
			get
			{
				return (int)_stream.Length;
			}
		}

		private MemoryStream _stream;

		private BinaryWriter _writer;

		private BinaryReader _reader;

		public Packet( byte[] content )
			: this( new MemoryStream( content ) )
		{
		}

		public Packet( MemoryStream stream )
		{
			_stream = stream;
			_reader = new BinaryReader( _stream );
			_writer = new BinaryWriter( _stream );
			this.Header = this.ReadInt();
		}

		public Packet( int header )
		{
			this.Header = header;
			_stream = new MemoryStream();
			_reader = new BinaryReader( _stream );
			_writer = new BinaryWriter( _stream );
			this.Write( header );
		}

		public T Read<T>()
		{
			var type = typeof( T );
			object result = null;
			if( type == typeof( bool ) )
			{
				result = this.ReadBool();
			}
			else if( type == typeof( byte ) )
			{
				result = this.ReadByte();
			}
			else if( type == typeof( short ) )
			{
				result = this.ReadShort();
			}
			else if( type == typeof( int ) )
			{
				result = this.ReadInt();
			}
			else if( type == typeof( long ) )
			{
				result = this.ReadLong();
			}
			else if( type == typeof( float ) )
			{
				result = this.ReadFloat();
			}
			else if( type == typeof( double ) )
			{
				result = this.ReadDouble();
			}
			else if( type == typeof( string ) )
			{
				result = this.ReadString();
			}
			else if( type == typeof( byte[] ) )
			{
				result = this.ReadByteBuffer();
			}
			else if( type == typeof( List<> ) )
			{
				var t = type.GetGenericArguments()[0];
				var readListGeneric = this.GetType().GetMethod( "ReadList`1" );
				var readList = readListGeneric.MakeGenericMethod( new Type[] { t } );
				result = readList.Invoke( this, null );
			}
			else if( type == typeof( HashSet<> ) )
			{
				var t = type.GetGenericArguments()[0];
				var readSetGeneric = this.GetType().GetMethod( "ReadSet`1" );
				var readSet = readSetGeneric.MakeGenericMethod( new Type[] { t } );
				result = readSet.Invoke( this, null );
			}
			else if( type == typeof( Dictionary<,> ) )
			{
				var k = type.GetGenericArguments()[0];
				var v = type.GetGenericArguments()[1];
				var readMapGeneric = this.GetType().GetMethod( "ReadMap`2" );
				var readMap = readMapGeneric.MakeGenericMethod( new Type[] { k, v } );
				result = readMap.Invoke( this, null );
			}
			else
			{
				throw new ArgumentException( "Brotorift do not recognize this type: " + type.Name );
			}

			return (T)result;
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

		public List<T> ReadList<T>()
		{
			var length = this.ReadInt();
			var list = new List<T>( length );
			for( int i = 0; i < length; i++ )
			{
				list.Add( this.Read<T>() );
			}
			return list;
		}

		public HashSet<T> ReadSet<T>()
		{
			var length = this.ReadInt();
			var set = new HashSet<T>();
			for( int i = 0; i < length; i++ )
			{
				set.Add( this.Read<T>() );
			}
			return set;
		}

		public Dictionary<K, V> ReadMap<K, V>()
		{
			var length = this.ReadInt();
			var map = new Dictionary<K, V>();
			for( int i = 0; i < length; i++ )
			{
				var key = this.Read<K>();
				var value = this.Read<V>();
				map.Add( key, value );
			}
			return map;
		}

		public T ReadEnum<T>() where T : struct, IConvertible
		{
			if( typeof( T ).IsEnum == false )
			{
				throw new ArgumentException( "T must be an enum type." );
			}

			var value = _reader.ReadInt32();
			return (T)Convert.ChangeType( value, typeof( T ) );
		}

		public void Write<T>( T value )
		{
			var type = value.GetType();
			var obj = (object)value;
			if( type == typeof( bool ) )
			{
				this.WriteBool( (bool)obj );
			}
			else if( type == typeof( byte ) )
			{
				this.WriteByte( (byte)obj );
			}
			else if( type == typeof( short ) )
			{
				this.WriteShort( (short)obj );
			}
			else if( type == typeof( int ) )
			{
				this.WriteInt( (int)obj );
			}
			else if( type == typeof( long ) )
			{
				this.WriteLong( (long)obj );
			}
			else if( type == typeof( float ) )
			{
				this.WriteFloat( (float)obj );
			}
			else if( type == typeof( double ) )
			{
				this.WriteDouble( (double)obj );
			}
			else if( type == typeof( string ) )
			{
				this.WriteString( (string)obj );
			}
			else if( type == typeof( byte[] ) )
			{
				this.WriteByteBuffer( (byte[])obj );
			}
			else if( type == typeof( List<> ) )
			{
				var t = type.GetGenericArguments()[0];
				var writeListGeneric = this.GetType().GetMethod( "WriteList`1" );
				var writeList = writeListGeneric.MakeGenericMethod( new Type[] { t } );
				writeList.Invoke( this, new object[] { obj } );
			}
			else if( type == typeof( HashSet<> ) )
			{
				var t = type.GetGenericArguments()[0];
				var writeSetGeneric = this.GetType().GetMethod( "WriteSet`1" );
				var writeSet = writeSetGeneric.MakeGenericMethod( new Type[] { t } );
				writeSet.Invoke( this, new object[] { obj } );
			}
			else if( type == typeof( Dictionary<,> ) )
			{
				var k = type.GetGenericArguments()[0];
				var v = type.GetGenericArguments()[0];
				var writeMapGeneric = this.GetType().GetMethod( "WriteMap`1" );
				var writeMap = writeMapGeneric.MakeGenericMethod( new Type[] { k, v } );
				writeMap.Invoke( this, new object[] { obj } );
			}
			else
			{
				throw new ArgumentException( "Brotorift do not recognize this type: " + type.Name );
			}
		}

		public void WriteBool( bool value )
		{
			_writer.Write( value );
		}

		public void WriteByte( byte value )
		{
			_writer.Write( value );
		}

		public void WriteShort( short value )
		{
			_writer.Write( value );
		}

		public void WriteInt( int value )
		{
			_writer.Write( value );
		}

		public void WriteLong( long value )
		{
			_writer.Write( value );
		}

		public void WriteFloat( float value )
		{
			_writer.Write( value );
		}

		public void WriteDouble( double value )
		{
			_writer.Write( value );
		}

		public void WriteString( string value )
		{
			_writer.Write( value );
		}

		public void WriteByteBuffer( byte[] value )
		{
			_writer.Write( value );
		}

		public void WriteList<T>( List<T> value )
		{
			this.WriteInt( value.Count );
			foreach( var item in value )
			{
				this.Write<T>( item );
			}
		}

		public void WriteSet<T>( HashSet<T> value )
		{
			this.WriteInt( value.Count );
			foreach( var item in value )
			{
				this.Write( item );
			}
		}

		public void WriteMap<K, V>( Dictionary<K, V> value )
		{
			this.WriteInt( value.Count );
			foreach( var item in value )
			{
				this.Write( item.Key );
				this.Write( item.Value );
			}
		}
	}
}
