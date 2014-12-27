node unity Client namespace Fitbos.Chat # aaaa
node scala LoginServer as L
node java XXX as X namespace org.fuck

struct UserInfo
	Long id
	String username
	String password
end

struct MyInfo
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
    Client -> L: RequestLogin
    Client <- L: RespondLogind
end