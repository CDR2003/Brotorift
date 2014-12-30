using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Brotorift
{
	public interface IStruct
	{
		void ReadFromPacket( Packet packet );

		void WriteToPacket( Packet packet );
	}
}
