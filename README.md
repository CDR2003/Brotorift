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

    include 'kljsdf'

    node unity Client namespace Fitbos.Chat # aaaa
    node scala ChatServer as S
    node java XXX as X namespace org.fuck

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
            String username     # Username
            String password     # Password
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
