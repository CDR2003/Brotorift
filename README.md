# Brotorift

## Types

### Base types

* Bool: byte(1)
* Byte: byte(1)
* Short, Int16: byte(2)
* Int, Int32: byte(4)
* Long, Int64: byte(8)
* Float: byte(4)
* Double: byte(8)
* String: byte(1) + byte(len)
* ByteBuffer: byte(1) + byte(len)
* List<T>: byte(4) + byte(T) * len
* Set<T>: byte(4) + byte(T) * len
* Map<K, V>: byte(4) + (byte(K) + byte(V)) * len
* Vector2: byte(Float) * 2
* Vector3: byte(Float) * 3

### User defined types

* Enum
* Struct

## Sample code

    namespace csharp TestClient.Protocols
    namespace scala org.fitbos.chatServer.protocols

    include XXXX

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
