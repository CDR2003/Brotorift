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

enum LoginResult
	Succeed
	InvalidUsername
	InvalidPassword
end

direction Client -> LoginServer
    message RequestLogin    # Login using the client user info
        String username		# Username
        String password		# Password
    end
end

direction Client <- LoginServer
	message RespondLogin
		LoginResult result
	end
end

sequence Login
    C -> L: RequestLogin
    L -> C: RespondLogin
end