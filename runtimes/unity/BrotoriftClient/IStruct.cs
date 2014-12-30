using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Brotorift
{
	public interface IStruct
	{
		void ReadFromPacket( InPacket packet );

		void WriteToPacket( OutPacket packet );
	}
}
