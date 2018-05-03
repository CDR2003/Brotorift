using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace Brotorift
{
	public enum ClientState
	{
		Disconnected,
		Connecting,
		Connected,
	}
}