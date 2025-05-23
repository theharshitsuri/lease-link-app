// === src/pages/AddListing.jsx ===
import React, { useState, useRef } from 'react';
import { supabase } from '../lib/supabaseClient';
import { useNavigate } from 'react-router-dom';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { v4 as uuidv4 } from 'uuid';
import { Autocomplete } from '@react-google-maps/api';

function AddListing() {
  const navigate = useNavigate();
  const [title, setTitle] = useState('');
  const [rent, setRent] = useState('');
  const [location, setLocation] = useState('');
  const [latitude, setLatitude] = useState(null);
  const [longitude, setLongitude] = useState(null);
  const [description, setDescription] = useState('');
  const [gender, setGender] = useState('Any');
  const [availableFrom, setAvailableFrom] = useState(null);
  const [availableTo, setAvailableTo] = useState(null);
  const [images, setImages] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const autoCompleteRef = useRef(null);
  const [inputValue, setInputValue] = useState('');

  const handleImageChange = (e) => {
    setImages([...e.target.files]);
  };

  const uploadImages = async () => {
    const urls = [];
    for (const file of images) {
      const fileExt = file.name.split('.').pop();
      const fileName = `${uuidv4()}.${fileExt}`;
      const { error } = await supabase.storage
        .from('listing-images')
        .upload(fileName, file, { upsert: true });
      if (error) throw error;
      const { publicUrl } = supabase.storage.from('listing-images').getPublicUrl(fileName).data;
      urls.push(publicUrl);
    }
    return urls;
  };

  const handlePlaceSelect = () => {
    const place = autoCompleteRef.current.getPlace();
    if (place && place.geometry) {
      const lat = place.geometry.location.lat();
      const lng = place.geometry.location.lng();
      setLatitude(lat);
      setLongitude(lng);
      setLocation(place.formatted_address);
      setInputValue(place.formatted_address);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!title || !rent || !location || !availableFrom || !availableTo || !latitude || !longitude) {
      alert('Please fill all required fields and select a valid location.');
      return;
    }

    setIsLoading(true);

    try {
      const imageUrls = await uploadImages();
      const { data: userData, error: userError } = await supabase.auth.getUser();
      if (userError || !userData?.user) {
        alert('User not authenticated');
        setIsLoading(false);
        return;
      }

      const user = userData.user;
      const listingPayload = {
        title,
        location,
        latitude,
        longitude,
        rent: parseFloat(rent),
        description,
        gender,
        available_from: availableFrom.toISOString(),
        available_to: availableTo.toISOString(),
        user_id: user.id,
        images: imageUrls,
      };

      console.log('Inserting listing:', listingPayload);
      const { error: insertError } = await supabase.from('listings').insert(listingPayload);

      if (insertError) {
        console.error('Insert error:', insertError);
        alert(`Error creating listing: ${insertError.message}`);
      } else {
        alert('Listing created successfully!');
        navigate('/home');
      }
    } catch (error) {
      console.error('Unexpected error:', error);
      alert(`Unexpected error: ${error.message || error}`);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="bg-black min-h-screen text-white px-6 py-10">
      <div className="max-w-2xl mx-auto">
        <h1 className="text-3xl font-bold text-white mb-8 text-center">Add New Listing</h1>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div
            className="w-full h-60 bg-[#1e1e1e] flex items-center justify-center rounded-xl cursor-pointer text-gray-400 border border-gray-700 hover:border-purple-500"
            onClick={() => document.getElementById('image-upload').click()}
          >
            {images.length === 0 ? 'Tap to upload images' : `${images.length} image(s) selected`}
            <input
              id="image-upload"
              type="file"
              accept="image/*"
              multiple
              onChange={handleImageChange}
              className="hidden"
            />
          </div>

          <input
            type="text"
            placeholder="Title"
            className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500
"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
          />

          <input
            type="number"
            placeholder="Rent ($)"
            className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500"
            value={rent}
            onChange={(e) => setRent(e.target.value)}
            required
          />

          <Autocomplete onLoad={(ref) => (autoCompleteRef.current = ref)} onPlaceChanged={handlePlaceSelect}>
            <input
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              placeholder="Search location..."
              className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500"
            />
          </Autocomplete>

          <textarea
            placeholder="Description"
            className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          ></textarea>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-gray-400">Gender Preference</label>
            <select
              value={gender}
              onChange={(e) => setGender(e.target.value)}
              className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white"
            >
              <option value="Any">Any</option>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
            </select>
          </div>

          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1">
              <label className="block mb-1 text-sm text-gray-400">Available From</label>
              <DatePicker
                selected={availableFrom}
                onChange={(date) => setAvailableFrom(date)}
                className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholderText="Select date"
              />
            </div>
            <div className="flex-1">
              <label className="block mb-1 text-sm text-gray-400">Available To</label>
              <DatePicker
                selected={availableTo}
                onChange={(date) => setAvailableTo(date)}
                className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholderText="Select date"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="bg-purple-600 hover:bg-purple-700 text-white px-6 py-3 rounded-xl w-full text-lg"
          >
            {isLoading ? 'Submitting...' : 'Submit Listing'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default AddListing;
