# Brotorift

## Types

### Base types

* Bool
* Short
* Int
* Long
* Float
* Double
* String
* ByteBuffer
* List<T>
* Set<T>
* Map<K, V>
* Vector2
* Vector3

### User defined types

* Enum
* Struct

## Sample code

    namespace csharp TestClient.Protocols
    namespace scala org.fitbos.chatServer.protocols

    include XXXX.b

    node Client as C            # The game client
    node LoginServer as L       # 
    node GameServer as G        # 游戏服务器

    struct UserInfo
        String username
        String password
    end

    enum LoginResult
        Succeeded = 0
        InvalidUsername
        InvalidPassword
    end

    direction Client -> LoginServer
        message RequestLogin    # Login using the client user info
            UserInfo info       # The client user info
        end

        message RequestLogin    # Login using the client user info
            UserInfo info       # The client user info
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
