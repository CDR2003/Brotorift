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
		public void RespondLogin( LoginResult result )
		{
			Console.WriteLine( result );
		}

		public void RespondRegister( RegisterResult result )
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
				var result = client.Update();
				if( result == false )
				{
					break;
				}
			}

			Console.WriteLine( "Connection lost." );
			Console.ReadKey();
		}
	}
}
