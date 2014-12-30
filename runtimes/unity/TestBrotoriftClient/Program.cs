using Fitbos.Chat;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestBrotoriftClient
{
	class Handler : ClientChatServerConnector.IHandler
	{
		public void SetNameResult( bool succeeded )
		{
			throw new NotImplementedException();
		}
	}


	class Program
	{
		static void Main( string[] args )
		{
			var client = new ClientChatServerConnector( new Handler() );
			client.Connect( "localhost", 9000 );
			client.SetName( "Fitbos" );

			client.Update();
			Console.ReadKey();
		}
	}
}
