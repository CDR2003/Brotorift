using Brotorift;
//using UnityEngine;
using System;
using System.Collections.Generic;
using System.Text;

namespace Fitbos.Chat
{
	#region Enums
	
	#endregion

	#region Structs
	
	#endregion

	
	public class ClientChatServerConnector : Client
	{
		public interface IHandler
		{
			/// <summary>
			/// The result of SetName
			/// </summary>
			/// <param name="succeeded">Is succeeded or not</param>
			void SetNameResult( bool succeeded );
		}

		private IHandler _handler;

		public ClientChatServerConnector( IHandler handler )
		{
			_handler = handler;
		}

		private enum InMessage
		{
			SetNameResult = 2001,
		}

		private enum OutMessage
		{
			SetName = 1001,
		}

		
		/// <summary>
		/// Set your chat nickname
		/// </summary>
		/// <param name="name">The nickname</param>
		public void SetName( string name )
		{
			var packet = new OutPacket( (int)OutMessage.SetName );
			packet.WriteString( name );
			this.SendPacket( packet );
		}

		protected override void ProcessPacket( InPacket packet )
		{
			switch( (InMessage)packet.Header )
			{
				
				case InMessage.SetNameResult:
					{
						var succeeded = packet.ReadBool();
						_handler.SetNameResult( succeeded );
					}
					break;
				default:
					break;
			}
		}
	}
	
}
