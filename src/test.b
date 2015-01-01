node unity ChatClient namespace Fitbos.Chat
node scala ChatServer namespace org.fitbos.chat

struct UserInfo
	String username
	String password
end

enum Weekdays
	Monday = 1
	Tuesday
	Wednesday
	Thursday
	Friday
	Saturday
	Sunday = 0
end

struct Test
	List<Map<Int, String>> aaa
	Weekdays day
end

enum YesNo
	Yes
	No
end

direction ChatClient -> ChatServer
	message SetName					# Set your chat nickname
		String name					# The nickname
		Map<Int, Set<String>> aaa
		UserInfo info
		YesNo yn
	end
end

direction ChatClient <- ChatServer
	message SetNameResult			# The result of SetName
		Bool succeeded				# Is succeeded or not
		Set<Set<String>> test
		UserInfo info
		YesNo yn
	end

	message AnotherMessage
	end
end