import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { useNavigate } from 'react-router-dom';
import ListingCard from '../components/ListingCard';

function MyListings() {
  const navigate = useNavigate();
  const [myListings, setMyListings] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchUserListings = async () => {
    const { data: userData } = await supabase.auth.getUser();
    const userId = userData?.user?.id;

    if (!userId) {
      navigate('/auth');
      return;
    }

    const { data, error } = await supabase
      .from('listings')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching listings:', error.message);
    } else {
      setMyListings(data);
    }

    setLoading(false);
  };

  const toggleFavorite = async (listingId, newValue) => {
    await supabase
      .from('listings')
      .update({ is_favorite: newValue })
      .eq('id', listingId);
    fetchUserListings();
  };

  useEffect(() => {
    fetchUserListings();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-black text-white flex justify-center items-center">
        <p className=" text-xl">Loading your listings...</p>
      </div>
    );
  }

  if (myListings.length === 0) {
    return (
      <div className="min-h-screen bg-black text-white flex justify-center items-center">
        <p className="text-gray-400 text-lg">You have not added any listings yet.</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen text-white px-4 py-10 max-w-screen-xl mx-auto">
      <h1 className="text-3xl font-bold mb-8 text-center text-white">My Listings</h1>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {myListings.map((listing) => (
          <ListingCard
            key={listing.id}
            listing={{
              id: listing.id,
              title: listing.title,
              address: listing.address || listing.location,
              rent: listing.rent,
              availableFrom: listing.available_from,
              availableTo: listing.available_to,
              images: listing.images || [],
              isFavorite: listing.is_favorite || false,
            }}
            onFavoriteToggle={() => toggleFavorite(listing.id, !listing.is_favorite)}
            onClick={() => navigate(`/listing/${listing.id}`)}
          />
        ))}
      </div>
    </div>
  );
}

export default MyListings;
