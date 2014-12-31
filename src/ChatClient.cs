using Brotorift;
using UnityEngine;
using System;
using System.Collections.Generic;
using System.Text;

namespace Fitbos.Chat
{
	#region Enums
	
	/// <summary>
	/// 
	/// </summary>
	public enum YesNo
	{
		/// <summary>
		/// 
		/// </summary>
		Yes = 0,
	
		/// <summary>
		/// 
		/// </summary>
		No = 1,
	}
	
	#endregion

	#region Structs
	
	/// <summary>
	/// 
	/// </summary>
	public struct UserInfo : IStruct
	{
		/// <summary>
		/// 
		/// </summary>
		public string username;
		
		/// <summary>
		/// 
		/// </summary>
		public string password;
		
		public void ReadFromPacket( InPacket packet )
		{
			this.username = packet.ReadString();
			this.password = packet.ReadString();
		}

		public void WriteToPacket( OutPacket packet )
		{
			packet.WriteString( username );
			packet.WriteString( password );
		}
	}
	
	#endregion
	
	public class ChatServerConnector : Client
	{
		public interface IHandler
		{
			/// <summary>
			/// The result of SetName
			/// </summary>
			/// <param name="succeeded">Is succeeded or not</param>/// <param name="test"></param>/// <param name="info"></param>/// <param name="yn"></param>
			void SetNameResult( bool succeeded, HashSet<HashSet<string>> test, UserInfo info, YesNo yn );
		}

		private IHandler _handler;

		public ChatServerConnector( IHandler handler )
		{
			_handler = handler;
		}

		private enum InMessage
		{
			SetNameResult = 2002,
		}

		private enum OutMessage
		{
			SetName = 1001,
		}
		
		/// <summary>
		/// Set your chat nickname
		/// </summary>
		/// <param name="name">The nickname</param>/// <param name="aaa"></param>/// <param name="info"></param>/// <param name="yn"></param>
		public void SetName( string name, Dictionary<int, HashSet<string>> aaa, UserInfo info, YesNo yn )
		{
			var packet = new OutPacket( (int)OutMessage.SetName );
			packet.WriteString( name );
			packet.WriteMap<int, HashSet<string>>( ( _1 ) => packet.WriteInt( _1 ), ( _2 ) => packet.WriteSet<string>( ( _3 ) => packet.WriteString( _3 ) ) );
			packet.WriteStruct( info );
			packet.WriteInt( (int)yn );
			this.SendPacket( packet );
		}

		protected override void ProcessPacket( InPacket packet )
		{
			switch( (InMessage)packet.Header )
			{
				case InMessage.SetNameResult:
					{
						var succeeded = packet.ReadBool();
						var test = packet.ReadSet<HashSet<string>>( () => packet.ReadSet<string>( () => packet.ReadString() ) );
						var info = packet.ReadStruct( new UserInfo() );
						var yn = (YesNo)packet.ReadInt();
						_handler.SetNameResult( succeeded, test, info, yn );
					}
					break;
				default:
					break;
			}
		}
	}
	
}
