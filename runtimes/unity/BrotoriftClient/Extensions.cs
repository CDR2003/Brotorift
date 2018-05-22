using System;

namespace Brotorift
{
    public static class Extensions
    {
		private static DateTime Epoch = new DateTime( 1970, 1, 1, 0, 0, 0, DateTimeKind.Utc );

        public static int ToUnixTime( this DateTime dateTime )
        {
            var timeOffset = dateTime.ToUniversalTime() - Epoch;
            return (int)timeOffset.TotalSeconds;
        }

        public static DateTime ToDateTime( this int timestamp )
        {
            var timeSpan = TimeSpan.FromSeconds( timestamp );
            return Epoch.Add( timeSpan ).ToLocalTime();
        }
    }
}