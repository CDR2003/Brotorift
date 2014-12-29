node unity ChatClient namespace Fitbos.Chat
node scala ChatServer namespace org.fitbos.chat

direction ChatClient -> ChatServer
	message SetName					# Set your chat nickname
		String name					# The nickname
	end
end

direction ChatClient <- ChatServer
	message SetNameResult			# The result of SetName
		Bool succeeded				# Is succeeded or not
	end
end