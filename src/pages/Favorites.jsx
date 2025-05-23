import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';
import ListingCard from '../components/ListingCard';

function Favorites() {
  const navigate = useNavigate();
  const [favorites, setFavorites] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchFavorites = async () => {
    const { data: userData } = await supabase.auth.getUser();
    const userId = userData?.user?.id;

    if (!userId) {
      navigate('/auth');
      return;
    }

    const { data: favoriteIds, error: favError } = await supabase
      .from('favorites')
      .select('listing_id')
      .eq('user_id', userId);

    if (favError || !favoriteIds?.length) {
      setFavorites([]);
      setLoading(false);
      return;
    }

    const listingIds = favoriteIds.map((fav) => fav.listing_id);

    const { data: listings, error: listingsError } = await supabase
      .from('listings')
      .select('*')
      .in('id', listingIds);

    if (listingsError) {
      console.error('Failed to load favorites:', listingsError.message);
    }

    setFavorites(listings || []);
    setLoading(false);
  };

  const toggleFavorite = async (listingId) => {
    const { data: userData } = await supabase.auth.getUser();
    const userId = userData?.user?.id;
    if (!userId) return;

    await supabase
      .from('favorites')
      .delete()
      .eq('user_id', userId)
      .eq('listing_id', listingId);

    fetchFavorites(); // refresh the list
  };

  useEffect(() => {
    fetchFavorites();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-black text-white flex justify-center items-center">
        <p className="text-lg">Loading your favorites...</p>
      </div>
    );
  }

  if (favorites.length === 0) {
    return (
      <div className="min-h-screen bg-black text-white flex justify-center items-center">
        <p className="text-gray-400 text-lg">No favorites yet.</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen text-white px-4 py-10 max-w-screen-xl mx-auto">
      <h1 className="text-3xl font-bold mb-8 text-center">Saved Listings</h1>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {favorites.map((listing) => (
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
              isFavorite: true,
            }}
            onFavoriteToggle={() => toggleFavorite(listing.id)}
            onClick={() => navigate(`/listing/${listing.id}`)}
          />
        ))}
      </div>
    </div>
  );
}

export default Favorites;
