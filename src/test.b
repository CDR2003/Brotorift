node unity ChatClient namespace Fitbos.Chat
node scala ChatServer namespace org.fitbos.chat

struct UserInfo
	String username
	String password
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
end