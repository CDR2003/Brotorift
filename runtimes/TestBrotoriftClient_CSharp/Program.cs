using Brotorift.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestBrotoriftClient_CSharp
{
	class Handler : IBrotoriftClientHandler
	{

		public void ReceiveLoginResult( LoginResult result )
		{
			throw new NotImplementedException();
		}
	}

	class Program
	{
		static void Main( string[] args )
		{
			var client = new BrotoriftClient( new Handler() );
			client.Disconnected += client_Disconnected;
			client.Connect( "localhost", 9000 );
			client.SetName( "lalala" );

			Console.ReadKey();
		}

		static void client_Disconnected( object sender, EventArgs e )
		{
			Console.WriteLine( "Disconnected from server." );
		}
	}
}
