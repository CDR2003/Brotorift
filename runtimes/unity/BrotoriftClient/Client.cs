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
		public ClientState CurrentState { get; private set; }

		public event Action connect;

		private TcpClient _client;

		private Thread _recvThread;

		private MemoryStream _recvBuffer;

		private NetworkStream _stream;

		private int _segmentSize;

		private Queue<InPacket> _packetsToReceive;

		private Queue<OutPacket> _packetsToSend;

		private Mutex _receivePacketsLock;

		private bool _justConnected;

		public Client()
			: this( 1024 )
		{
		}

		public Client( int segmentSize )
		{
			_segmentSize = segmentSize;
			_receivePacketsLock = new Mutex();
			_packetsToReceive = new Queue<InPacket>();
			_packetsToSend = new Queue<OutPacket>();

			this.CurrentState = ClientState.Disconnected;
		}

		public void Connect( string hostname, int port )
		{
			if( this.CurrentState == ClientState.Connecting || this.CurrentState == ClientState.Connected )
			{
				return;
			}

			_client = new TcpClient();
			_recvBuffer = new MemoryStream();
			_packetsToReceive.Clear();
			_packetsToSend.Clear();

			_client.Connect( hostname, port );
			_justConnected = true;
			this.CurrentState = ClientState.Connected;

			_stream = _client.GetStream();
			_recvThread = new Thread( this.ReceiveLoop );
			_recvThread.Start();
		}

		public void BeginConnect( string hostname, int port )
		{
			if( this.CurrentState == ClientState.Connected )
			{
				return;
			}

			_client = new TcpClient();
			_recvBuffer = new MemoryStream();
			_packetsToReceive.Clear();
			_packetsToSend.Clear();

			this.CurrentState = ClientState.Connecting;
			_client.BeginConnect( hostname, port, this.OnConnected, null );
		}

		public void Close()
		{
			if( this.CurrentState == ClientState.Disconnected )
			{
				return;
			}

			this.CurrentState = ClientState.Disconnected;
			_client.Close();
			_recvThread.Join();
		}

		public void Update()
		{
			if( _justConnected )
			{
				_justConnected = false;
				if( this.connect != null )
				{
					this.connect();
				}
			}

			_receivePacketsLock.WaitOne();
			while( _packetsToReceive.Count > 0 )
			{
				var packet = _packetsToReceive.Dequeue();
				if( packet == null )
				{
					_receivePacketsLock.ReleaseMutex();
					this.Close();
					return;
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
					this.Close();
					return;
				}
			}

			return;
		}

		private void OnConnected( IAsyncResult result )
		{
			if( _client.Connected == false )
			{
				this.CurrentState = ClientState.Disconnected;
				return;
			}

			this.CurrentState = ClientState.Connected;
			_client.EndConnect( result );
			_stream = _client.GetStream();
			_recvThread = new Thread( this.ReceiveLoop );
			_recvThread.Start();

			_justConnected = true;
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
					else
					{
						_receivePacketsLock.WaitOne();
						_packetsToReceive.Enqueue( null );
						_receivePacketsLock.ReleaseMutex();
						break;
					}
					this.PushPackets();
				}
			}
			catch( Exception )
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
			catch( Exception )
			{
				return false;
			}

			return true;
		}

		protected abstract void ProcessPacket( InPacket packet );
	}
}
