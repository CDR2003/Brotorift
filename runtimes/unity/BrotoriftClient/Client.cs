using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace Brotorift
{
	public abstract class Client
	{
		private TcpClient _client;

		private Thread _recvThread;

		private MemoryStream _recvBuffer;

		private NetworkStream _stream;

		private int _segmentSize;

		private Queue<InPacket> _packetsToReceive;

		private Queue<OutPacket> _packetsToSend;

		private Mutex _receivePacketsLock;

		public Client()
			: this( 1024 )
		{
		}

		public Client( int segmentSize )
		{
			_segmentSize = segmentSize;
			_receivePacketsLock = new Mutex();
			_recvThread = new Thread( this.ReceiveLoop );
		}

		public void Connect( string hostname, int port )
		{
			_client = new TcpClient();
			_recvBuffer = new MemoryStream();
			_packetsToReceive = new Queue<InPacket>();
			_packetsToSend = new Queue<OutPacket>();

			_client.Connect( hostname, port );
			_stream = _client.GetStream();
			_recvThread.Start();
		}

		public IAsyncResult BeginConnect( string hostname, int port, AsyncCallback callback, object state )
		{
			return _client.BeginConnect( hostname, port, callback, state );
		}

		public void EndConnect( IAsyncResult asyncResult )
		{
			_client.EndConnect( asyncResult );
			_stream = _client.GetStream();
			_recvThread.Start();
		}

		public void Close()
		{
			_client.Close();
		}

		public bool Update()
		{
			_receivePacketsLock.WaitOne();
			while( _packetsToReceive.Count > 0 )
			{
				var packet = _packetsToReceive.Dequeue();
				if( packet == null )
				{
					return false;
				}
				this.ProcessPacket( packet );
			}
			_receivePacketsLock.ReleaseMutex();

			while( _packetsToSend.Count > 0 )
			{
				var packet = _packetsToSend.Dequeue();
				var result = this.DoSendPacket( packet );
				if( result == false )
				{
					return false;
				}
			}

			return true;
		}

		private void ReceiveLoop()
		{
			try
			{
				for( ; ; )
				{
					var segment = new byte[_segmentSize];
					var bytesRead = _stream.Read( segment, 0, _segmentSize );
					if( bytesRead > 0 )
					{
						var currentPosition = 0;
						_recvBuffer.Write( segment, 0, bytesRead );
						while( bytesRead == _segmentSize && _stream.DataAvailable )
						{
							bytesRead = _stream.Read( segment, 0, _segmentSize );
							_recvBuffer.Write( segment, 0, bytesRead );
							currentPosition += bytesRead;
						}
					}
					this.PushPackets();
				}
			}
			catch( IOException )
			{
				_receivePacketsLock.WaitOne();
				_packetsToReceive.Enqueue( null );
				_receivePacketsLock.ReleaseMutex();
			}
		}

		private void PushPackets()
		{
			_recvBuffer.Position = 0;
			while( _recvBuffer.Length - _recvBuffer.Position > sizeof( int ) )
			{
				var reader = new BinaryReader( _recvBuffer );
				var packetSize = reader.ReadInt32();
				if( _recvBuffer.Length - _recvBuffer.Position < packetSize )
				{
					_recvBuffer.Position -= sizeof( int );
					break;
				}

				var content = reader.ReadBytes( packetSize );
				_receivePacketsLock.WaitOne();
				_packetsToReceive.Enqueue( new InPacket( new MemoryStream( content ) ) );
				_receivePacketsLock.ReleaseMutex();
			}

			if( _recvBuffer.Position > 0 )
			{
				var newBuffer = new MemoryStream();
				newBuffer.Write( _recvBuffer.GetBuffer(), (int)_recvBuffer.Position, (int)( _recvBuffer.Length - _recvBuffer.Position ) );
				_recvBuffer = newBuffer;
			}
		}

		protected void SendPacket( OutPacket packet )
		{
			_packetsToSend.Enqueue( packet );
		}

		private bool DoSendPacket( OutPacket packet )
		{
			var stream = new MemoryStream();
			var writer = new BinaryWriter( stream );
			writer.Write( packet.Length );
			writer.Write( packet.Buffer, 0, packet.Length );

			try
			{
				_stream.Write( stream.GetBuffer(), 0, (int)stream.Length );
			}
			catch( IOException )
			{
				return false;
			}

			return true;
		}

		protected abstract void ProcessPacket( InPacket packet );
	}
}
