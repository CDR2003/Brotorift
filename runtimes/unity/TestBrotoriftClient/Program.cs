using Brotorift;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestBrotoriftClient
{
	class ChatServerConnector : ChatServerConnectorBase
	{
		protected override void RespondLogin( LoginResult result )
		{
			Console.WriteLine( result );
		}

		protected override void RespondRegister( RegisterResult result )
		{
			throw new NotImplementedException();
		}
	}

	class Program
	{
		static void Main( string[] args )
		{
			var client = new ChatServerConnector();
			client.Connect( "localhost", 9000 );

			var info = new UserInfo();
			info.username = "Fitbos";
			info.password = "123";
			client.RequestLogin( info );

			for( ; ; )
			{
				client.Update();
				if( client.CurrentState == ClientState.Disconnected )
				{
					break;
				}
			}

			Console.WriteLine( "Connection lost." );
			Console.ReadKey();
		}
	}
}
