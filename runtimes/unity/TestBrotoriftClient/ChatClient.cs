using Brotorift;
using System;
using System.Collections.Generic;
using System.Text;

namespace TestBrotoriftClient
{
	#region Enums
	
	/// <summary>
	/// 登录结果
	/// </summary>
	public enum LoginResult
	{
		/// <summary>
		/// 成功
		/// </summary>
		Succeeded = 0,
	
		/// <summary>
		/// 用户名不存在
		/// </summary>
		InvalidUsername = 1,
	
		/// <summary>
		/// 密码错误
		/// </summary>
		InvalidPassword = 2,
	}
	
	/// <summary>
	/// 注册结果
	/// </summary>
	public enum RegisterResult
	{
		/// <summary>
		/// 成功
		/// </summary>
		Succeeded = 0,
	
		/// <summary>
		/// 重复用户名已存在
		/// </summary>
		DuplicateUsername = 1,
	}
	
	#endregion

	#region Structs
	
	/// <summary>
	/// 用户信息
	/// </summary>
	public struct UserInfo : IStruct
	{
		/// <summary>
		/// 用户名
		/// </summary>
		public string username;
		
		/// <summary>
		/// 密码
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
			/// 回复登录请求
			/// </summary>
			/// <param name="result">登录结果</param>
			void RespondLogin( LoginResult result );
		
			/// <summary>
			/// 回复注册请求
			/// </summary>
			/// <param name="result">注册结果</param>
			void RespondRegister( RegisterResult result );
		}

		private IHandler _handler;

		public ChatServerConnector( IHandler handler )
		{
			_handler = handler;
		}

		private enum InMessage
		{
			RespondLogin = 2001,
			RespondRegister = 2002,
		}

		private enum OutMessage
		{
			RequestLogin = 1001,
			RequestRegister = 1002,
		}
		
		/// <summary>
		/// 请求登录
		/// </summary>
		/// <param name="info">登录时填写的用户信息</param>
		public void RequestLogin( UserInfo info )
		{
			var packet = new OutPacket( (int)OutMessage.RequestLogin );
			packet.WriteStruct( info );
			this.SendPacket( packet );
		}
		/// <summary>
		/// 请求注册
		/// </summary>
		/// <param name="info">注册时填写的用户信息</param>
		public void RequestRegister( UserInfo info )
		{
			var packet = new OutPacket( (int)OutMessage.RequestRegister );
			packet.WriteStruct( info );
			this.SendPacket( packet );
		}

		protected override void ProcessPacket( InPacket packet )
		{
			switch( (InMessage)packet.Header )
			{
				case InMessage.RespondLogin:
					{
						var result = (LoginResult)packet.ReadInt();
						_handler.RespondLogin( result );
					}
					break;
				case InMessage.RespondRegister:
					{
						var result = (RegisterResult)packet.ReadInt();
						_handler.RespondRegister( result );
					}
					break;
				default:
					break;
			}
		}
	}
	
}
