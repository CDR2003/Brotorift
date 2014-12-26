using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace Brotorift.Client
{
	#region Generated Enums & Structs

	#region Enums

	public enum LoginResult
	{
		Succeed,
		InvalidUsername,
		InvalidPassword
	}

	#endregion

	#region Structs
	#endregion

	#endregion

	public class BrotoriftClient
	{
		#region Runtime

		public event EventHandler Disconnected;

		private IBrotoriftClientHandler _handler;

		private TcpClient _client;

		private Thread _recvThread;

		private MemoryStream _recvBuffer;

		private NetworkStream _stream;

		private int _segmentSize;

		private Queue<BrotoriftPacket> _packets;

		private Mutex _packetsLock;

		public BrotoriftClient( IBrotoriftClientHandler handler )
			: this( handler, 1024 )
		{
		}

		public BrotoriftClient( IBrotoriftClientHandler handler, int segmentSize )
		{
			_handler = handler;
			_client = new TcpClient();
			_recvThread = new Thread( this.ReceiveLoop );
			_recvBuffer = new MemoryStream();
			_segmentSize = segmentSize;
			_packets = new Queue<BrotoriftPacket>();
			_packetsLock = new Mutex();
		}

		public void Connect( string hostname, int port )
		{
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

		public void Update()
		{
			_packetsLock.WaitOne();
			while( _packets.Count > 0 )
			{
				var packet = _packets.Dequeue();
				if( packet == null )
				{
					if( this.Disconnected != null )
					{
						this.Disconnected( this, EventArgs.Empty );
					}
					return;
				}
				this.ProcessPacket( packet );
			}
			_packetsLock.ReleaseMutex();
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
						_recvBuffer.Write( segment, currentPosition, bytesRead );
						currentPosition += bytesRead;
						while( bytesRead == _segmentSize && _stream.DataAvailable )
						{
							bytesRead = _stream.Read( segment, 0, _segmentSize );
							_recvBuffer.Write( segment, currentPosition, bytesRead );
							currentPosition += bytesRead;
						}
					}
					this.PushPackets();
				}
			}
			catch( IOException )
			{
				_packetsLock.WaitOne();
				_packets.Enqueue( null );
				_packetsLock.ReleaseMutex();
			}
		}

		private void PushPackets()
		{
			while( _recvBuffer.Length > sizeof( int ) )
			{
				var reader = new BinaryReader( _recvBuffer );
				var packetSize = reader.ReadInt32();
				if( _recvBuffer.Length - _recvBuffer.Position < packetSize )
				{
					_recvBuffer.Position -= sizeof( int );
					break;
				}

				var content = reader.ReadBytes( packetSize );
				_packetsLock.WaitOne();
				_packets.Enqueue( new BrotoriftPacket( content ) );
				_packetsLock.ReleaseMutex();
			}

			if( _recvBuffer.Position > 0 )
			{
				var newBuffer = new MemoryStream( _recvBuffer.GetBuffer(), (int)_recvBuffer.Position, (int)( _recvBuffer.Length - _recvBuffer.Position ) );
				_recvBuffer = newBuffer;
			}
		}

		private void SendPacket( BrotoriftPacket packet )
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
				if( this.Disconnected != null )
				{
					this.Disconnected( this, EventArgs.Empty );
				}
			}
		}

		#endregion

		#region Generated

		#region Message Headers

		private enum Message
		{
			// Client -> LoginServer
			CL_Login = 0,
			SetName = 0,

			// LoginServer -> Client
			LC_ReceiveLoginResult = 100
		}

		#endregion

		#region Message Senders

		public void SetName( string name )
		{
			var packet = new BrotoriftPacket( (int)Message.SetName );
			packet.WriteString( name );
			this.SendPacket( packet );
		}

		#endregion

		#region Message Receivers

		private void ProcessPacket( BrotoriftPacket packet )
		{
			var packetId = (Message)packet.Header;
			switch( packetId )
			{
				case Message.LC_ReceiveLoginResult:
					{
						var result = packet.ReadEnum<LoginResult>();
						_handler.ReceiveLoginResult( result );
					}
					break;
				default:
					break;
			}
		}

		#endregion

		#endregion
	}
}
