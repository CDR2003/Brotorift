using Brotorift.Client.Protocol;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Brotorift.Client
{
	public interface IBrotoriftClientHandler
	{
		void ReceiveLoginResult( LoginResult result );
	}
}
