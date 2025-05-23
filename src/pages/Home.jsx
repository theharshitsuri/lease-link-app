import React, { useEffect, useState, useRef } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Autocomplete } from '@react-google-maps/api';
import { supabase } from '../lib/supabaseClient';
import ListingCard from '../components/ListingCard';
import { getDistanceFromLatLonInKm } from '../utils/Distance';
import { MessageSquare } from 'lucide-react'; // optional icon lib

function Home() {
  const [listings, setListings] = useState([]);
  const [locationCoords, setLocationCoords] = useState(null);
  const navigate = useNavigate();
  const [inputValue, setInputValue] = useState('');
  const autoCompleteRef = useRef(null);

  const fetchListings = async () => {
    const { data, error } = await supabase.from('listings').select('*');
    if (error) {
      console.error('Error fetching listings:', error);
      return;
    }

    let enriched = data;

    if (locationCoords) {
      enriched = enriched.map((l) => {
        const lat = l.latitude;
        const lng = l.longitude;
        const dist =
          lat && lng ? getDistanceFromLatLonInKm(locationCoords.lat, locationCoords.lng, lat, lng) : Infinity;
        return { ...l, distance: dist };
      });
      enriched.sort((a, b) => a.distance - b.distance);
    }

    setListings(enriched);
  };

  useEffect(() => {
    fetchListings();
  }, [locationCoords]);

  const handlePlaceSelect = () => {
    const place = autoCompleteRef.current.getPlace();
    if (place && place.geometry) {
      const lat = place.geometry.location.lat();
      const lng = place.geometry.location.lng();
      setLocationCoords({ lat, lng });
      setInputValue(place.formatted_address);
    }
  };

  return (
    <div className="max-w-screen-xl mx-auto px-4 py-10 relative">
      {/* Header Row */}
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-white">Explore</h1>
        <Link to="/chatlist" className="p-2 rounded-full hover:bg-white/10 transition">
          <MessageSquare size={24} className="text-white" />
        </Link>
      </div>

      {/* Location Search */}
      <div className="mb-8 relative">
        <Autocomplete onLoad={(ref) => (autoCompleteRef.current = ref)} onPlaceChanged={handlePlaceSelect}>
          <input
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="Search by city or address..."
            className="w-full p-4 rounded-xl bg-[#1e1e1e] text-white placeholder-gray-400 border border-purple-500 focus:outline-none focus:ring-2 focus:ring-purple-400"
          />
        </Autocomplete>
      </div>

      {/* Listings Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
        {listings.map((listing) => (
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
            onFavoriteToggle={() => {
              console.log('Toggled favorite:', listing.id);
            }}
            onClick={() => {
              navigate(`/listing/${listing.id}`);
            }}
          />
        ))}
      </div>
    </div>
  );
}

export default Home;
