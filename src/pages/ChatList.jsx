import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { useNavigate } from 'react-router-dom';

function ChatList() {
  const navigate = useNavigate();
  const [chats, setChats] = useState([]);
  const [currentUserId, setCurrentUserId] = useState(null);

  useEffect(() => {
    const fetchChats = async () => {
      const { data: userData } = await supabase.auth.getUser();
      if (!userData?.user) return;
      const userId = userData.user.id;
      setCurrentUserId(userId);

      const { data: chatData, error } = await supabase
        .from('chats')
        .select('*, messages:messages(text, created_at), user1:profiles(*), user2:profiles(*)')
        .or(`user1.eq.${userId},user2.eq.${userId}`)
        .order('updated_at', { ascending: false });

      if (error) {
        console.error('Error fetching chats:', error);
        return;
      }

      const processed = chatData.map((chat) => {
        const otherUser = chat.user1.id === userId ? chat.user2 : chat.user1;
        return {
          id: chat.id,
          name: otherUser.name || 'User',
          image: otherUser.profile_image_url,
          lastMessage: chat.messages?.length > 0 ? chat.messages[chat.messages.length - 1].text : 'Say hi!',
        };
      });

      setChats(processed);
    };

    fetchChats();
  }, []);

  return (
    <div className="max-w-screen-md mx-auto px-4 py-10">
      <h1 className="text-3xl font-bold text-white mb-6 text-center">Chats</h1>

      {chats.length === 0 ? (
        <p className="text-gray-400 text-center">No conversations yet.</p>
      ) : (
        <div className="space-y-4">
          {chats.map((chat) => (
            <div
              key={chat.id}
              onClick={() => navigate(`/chat/${chat.id}`)}
              className="flex items-center bg-[#1e1e1e] p-4 rounded-xl hover:bg-[#2c2c2c] cursor-pointer transition"
            >
              <img
                src={chat.image || '/default-avatar.png'}
                alt={chat.name}
                className="w-12 h-12 rounded-full object-cover mr-4"
              />
              <div>
                <h2 className="text-white font-semibold">{chat.name}</h2>
                <p className="text-gray-400 text-sm truncate">{chat.lastMessage}</p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default ChatList;
