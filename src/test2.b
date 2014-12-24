include 'kljsdf'

namespace csharp Fitbos.Game
namespace scala org.fitbos.game

node Client
node Client # aaaa
node Server as S
node Server as S # dsfkldfskljdfs

struct UserInfo
	String username
	Map<Int, String> users
	List<UserInfo> realUsers
end

enum Weekdays
	Monday
	Tuesday
	Friday = 5
	Saturday
	Sunday = 10 # Yeah!!
end

direction Client -> LoginServer
    message RequestLogin    # Login using the client user info
        UserInfo info       # The client user info
    end

    message RequestLogin    # Login using the client user info
        UserInfo info       # The client user info
        List<UserInfo> onlineUsers
        Map<Int, UserInfo> allUsers
    end
end

sequence Login
    C -> L: RequestLogin
    L -> C: RespondLogin
end