// === src/pages/ListingDetail.jsx ===
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';
import { ChevronLeft, ChevronRight, ImageOff } from 'lucide-react';

function ListingDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [listing, setListing] = useState(null);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [user, setUser] = useState(null);

  useEffect(() => {
    const fetchListing = async () => {
      const { data } = await supabase.from('listings').select('*').eq('id', id).single();
      setListing(data);
    };

    const getUser = async () => {
      const session = await supabase.auth.getSession();
      setUser(session.data.session?.user || null);
    };

    fetchListing();
    getUser();
  }, [id]);

  const handleContactLister = async () => {
    if (!user || !listing?.user_id) return;

    const uid = user.id;
    const lid = listing.user_id;

    const { data: existingChats } = await supabase
      .from('chats')
      .select('id')
      .or(`and(user1.eq.${uid},user2.eq.${lid}),and(user1.eq.${lid},user2.eq.${uid})`);

    let chatId;

    if (existingChats?.length) {
      chatId = existingChats[0].id;
    } else {
      const { data: newChat, error: chatError } = await supabase
        .from('chats')
        .insert([{ user1: uid, user2: lid }])
        .select()
        .single();

      if (chatError || !newChat) {
        console.error('Chat creation failed:', chatError);
        alert('Unable to contact lister.');
        return;
      }

      chatId = newChat.id;
    }

    navigate(`/chat/${chatId}`);
  };

  if (!listing) return <div className="text-white p-8">Loading...</div>;

  const isMyListing = user?.id === listing.user_id;
  const images = listing.images || [];
  const currentImage = images.length > 0 ? images[currentImageIndex] : null;

  const handlePrevImage = () =>
    setCurrentImageIndex((prev) => (prev - 1 + images.length) % images.length);
  const handleNextImage = () =>
    setCurrentImageIndex((prev) => (prev + 1) % images.length);

  const handleDelete = async () => {
    await supabase.from('listings').delete().eq('id', id);
    navigate('/');
  };

  return (
    <div className="bg-black min-h-screen text-white p-6 md:p-10">
      <div className="max-w-5xl mx-auto flex flex-col md:flex-row gap-8">
        <div className="w-full md:w-1/2 relative">
          <div className="rounded-xl overflow-hidden h-80 bg-[#1e1e1e] flex justify-center items-center">
            {currentImage ? (
              <img src={currentImage} alt="Listing" className="w-full h-full object-cover" />
            ) : (
              <div className="text-center text-white/60">
                <ImageOff size={40} className="mx-auto mb-2" />
                No photos available
              </div>
            )}
            {images.length > 1 && (
              <>
                <button onClick={handlePrevImage} className="absolute top-1/2 left-2 -translate-y-1/2 bg-black/50 p-2 rounded-full">
                  <ChevronLeft className="text-white" />
                </button>
                <button onClick={handleNextImage} className="absolute top-1/2 right-2 -translate-y-1/2 bg-black/50 p-2 rounded-full">
                  <ChevronRight className="text-white" />
                </button>
              </>
            )}
          </div>
        </div>

        <div className="w-full md:w-1/2">
          <h2 className="text-3xl font-bold mb-2">{listing.title}</h2>
          <p className="text-gray-400 mb-2">{listing.location} · ${listing.rent}/month</p>
          <p className="text-white mb-1">Available from: {listing.available_from}</p>
          {listing.available_to && <p className="text-white mb-1">Available to: {listing.available_to}</p>}
          <p className="text-white mb-1">Gender Preference: {listing.gender}</p>
          <div className="mt-6">
            <h3 className="text-xl font-bold mb-2">Description</h3>
            <p className="text-white">{listing.description}</p>
          </div>

          <div className="mt-8 flex gap-4">
            {isMyListing ? (
              <>
                <button
                  onClick={() => navigate(`/edit/${listing.id}`)}
                  className="bg-purple-600 hover:bg-purple-700 px-4 py-2 rounded-md"
                >
                  Edit
                </button>
                <button
                  onClick={handleDelete}
                  className="bg-red-600 hover:bg-red-700 px-4 py-2 rounded-md"
                >
                  Delete
                </button>
              </>
            ) : (
              <button
                onClick={handleContactLister}
                className="bg-purple-600 hover:bg-purple-700 px-6 py-3 rounded-lg mt-4 text-white"
              >
                Contact Lister
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default ListingDetail;
