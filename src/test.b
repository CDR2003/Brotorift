include XXXX

node Client namespace TestClient as C
node LoginServer namespace org.fitbos.loginServer as L
node GameServer as G

struct UserInfo
    String username
    String password
end

enum LoginResult
    Succeeded = -1
    InvalidUsername = 0x11
    InvalidPassword
    Fuck = 100
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

direction LoginServer -> Client
    message RespondLogin    # Respond to the login message
        LoginResult result  # The login result
    end
end

sequence Login
    C -> L: RequestLogin
    L -> C: RespondLogin
end