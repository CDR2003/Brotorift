using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;

namespace Brotorift
{
	public class OutPacket
	{
		public int Length
		{
			get
			{
				return (int)_stream.Length;
			}
		}

		public byte[] Buffer
		{
			get
			{
				return _stream.GetBuffer();
			}
		}

		private MemoryStream _stream;

		private BinaryWriter _writer;

		public OutPacket( int header )
		{
			_stream = new MemoryStream();
			_writer = new BinaryWriter( _stream );
			_writer.Write( header );
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
			var buffer = Encoding.UTF8.GetBytes( value );
			this.WriteByteBuffer( buffer );
		}

		public void WriteByteBuffer( byte[] value )
		{
			this.WriteInt( value.Length );
			_writer.Write( value );
		}

		public void WriteList<T>( List<T> value, Action<T> writeElement )
		{
			this.WriteInt( value.Count );
			foreach( var item in value )
			{
				writeElement( item );
			}
		}

		public void WriteSet<T>( HashSet<T> value, Action<T> writeElement )
		{
			this.WriteInt( value.Count );
			foreach( var item in value )
			{
				writeElement( item );
			}
		}

		public void WriteMap<K, V>( Dictionary<K, V> value, Action<K> writeKey, Action<V> writeValue )
		{
			this.WriteInt( value.Count );
			foreach( var item in value )
			{
				writeKey( item.Key );
				writeValue( item.Value );
			}
		}

		public void WriteStruct( IStruct value )
		{
			value.WriteToPacket( this );
		}

		public void WriteVector2( Vector2 value )
		{
			this.WriteFloat( value.x );
			this.WriteFloat( value.y );
		}

		public void WriteVector3( Vector3 value )
		{
			this.WriteFloat( value.x );
			this.WriteFloat( value.y );
			this.WriteFloat( value.z );
		}

		public void WriteColor( Color value )
		{
			this.WriteFloat( value.r );
			this.WriteFloat( value.g );
			this.WriteFloat( value.b );
			this.WriteFloat( value.a );
		}
	}
}
