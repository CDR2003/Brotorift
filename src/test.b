node unity Client as C namespace Fitbos.ChatServer
node scala LoginServer as L namespace org.fitbos.chatServer

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
    C <- L: RespondLogin
end