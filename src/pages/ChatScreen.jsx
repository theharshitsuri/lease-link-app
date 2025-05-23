import React, { useEffect, useState, useRef } from 'react';
import { useParams } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';
import dayjs from 'dayjs';

function ChatScreen() {
  const { chatId } = useParams();
  const [messages, setMessages] = useState([]);
  const [currentUser, setCurrentUser] = useState(null);
  const [input, setInput] = useState('');
  const [showTimestamps, setShowTimestamps] = useState(new Set());
  const scrollRef = useRef();

  useEffect(() => {
    const init = async () => {
      const { data } = await supabase.auth.getSession();
      const user = data.session?.user;
      setCurrentUser(user);

      const { data: messagesData } = await supabase
        .from('messages')
        .select('*')
        .eq('chat_id', chatId)
        .order('timestamp', { ascending: true });

      if (messagesData) setMessages(messagesData);
      scrollToBottom();

      supabase
        .channel(`chat-${chatId}`)
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'messages',
            filter: `chat_id=eq.${chatId}`,
          },
          (payload) => {
            setMessages((prev) => [...prev, payload.new]);
            scrollToBottom();
          }
        )
        .subscribe();
    };

    init();
    return () => {
      supabase.removeAllChannels();
    };
  }, [chatId]);

  const handleSend = async () => {
    if (!input.trim() || !currentUser) return;

    await supabase.from('messages').insert({
      chat_id: chatId,
      sender_id: currentUser.id,
      content: input.trim(),
      read: false,
    });

    setInput('');
  };

  const toggleTimestamp = (idx) => {
    setShowTimestamps((prev) => {
      const copy = new Set(prev);
      copy.has(idx) ? copy.delete(idx) : copy.add(idx);
      return copy;
    });
  };

  const scrollToBottom = () => {
    scrollRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <div className="flex justify-center bg-black min-h-screen px-4 py-10 text-white">
      <div className="w-full max-w-2xl h-[80vh] flex flex-col border border-purple-600 rounded-xl overflow-hidden">
        <div className="bg-[#1e1e1e] border-b border-purple-600 px-6 py-4 font-semibold">
          Chat
        </div>

        <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-[#121212]">
          {messages.map((msg, idx) => {
            const isMine = msg.sender_id === currentUser?.id;
            const showTime = showTimestamps.has(idx);

            return (
              <div
                key={msg.id}
                className={`flex ${isMine ? 'justify-end' : 'justify-start'}`}
                onClick={() => toggleTimestamp(idx)}
              >
                <div className="max-w-[70%]">
                  <div
                    className={`px-4 py-2 text-sm rounded-xl ${
                      isMine
                        ? 'bg-purple-600 text-white rounded-br-none'
                        : 'bg-gray-700 text-white rounded-bl-none'
                    }`}
                  >
                    {msg.content}
                  </div>
                  {showTime && (
                    <div className="text-xs text-gray-400 mt-1 italic">
                      {dayjs(msg.timestamp).format('h:mm A')}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
          <div ref={scrollRef} />
        </div>

        <div className="flex items-center border-t border-purple-600 bg-[#1e1e1e] p-3">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            placeholder="Type a message..."
            className="flex-1 p-3 rounded-full bg-black text-white placeholder-white/40 border border-purple-600 focus:outline-none"
          />
          <button
            onClick={handleSend}
            className="ml-3 bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-full"
          >
            send
          </button>
        </div>
      </div>
    </div>
  );
}

export default ChatScreen;
