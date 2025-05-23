import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';
import { v4 as uuidv4 } from 'uuid';

function EditProfile() {
  const navigate = useNavigate();
  const [profile, setProfile] = useState(null);
  const [name, setName] = useState('');
  const [age, setAge] = useState('');
  const [gender, setGender] = useState('Male');
  const [profileImage, setProfileImage] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchProfile = async () => {
      const { data: userData } = await supabase.auth.getUser();
      if (!userData?.user) return navigate('/auth');

      const { data: profileData } = await supabase
        .from('profiles')
        .select()
        .eq('id', userData.user.id)
        .single();

      if (profileData) {
        setProfile(profileData);
        setName(profileData.name || '');
        setAge(profileData.age || '');
        setGender(profileData.gender || 'Male');
      }
      setIsLoading(false);
    };

    fetchProfile();
  }, [navigate]);

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setProfileImage(file);
    }
  };

  const uploadImage = async (file) => {
    const fileExt = file.name.split('.').pop();
    const fileName = `${uuidv4()}.${fileExt}`;
    const { error } = await supabase.storage
      .from('profile-images')
      .upload(fileName, file, { upsert: true });

    if (error) throw error;

    const { data } = supabase.storage.from('profile-images').getPublicUrl(fileName);
    return data.publicUrl;
  };

  const handleSave = async () => {
    let imageUrl = profile?.profile_image_url;

    if (profileImage) {
      imageUrl = await uploadImage(profileImage);
    }

    const { data: userData } = await supabase.auth.getUser();
    await supabase
      .from('profiles')
      .update({
        name: name.trim(),
        age: parseInt(age) || 0,
        gender,
        profile_image_url: imageUrl,
      })
      .eq('id', userData.user.id);

    navigate('/profile');
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-black text-white">
        Loading profile...
      </div>
    );
  }

  return (
    <div className="bg-black min-h-screen text-white flex items-center justify-center">
      <div className="bg-[#1e1e1e] rounded-2xl p-10 shadow-xl w-full max-w-md space-y-6 text-center">
        <div className="relative w-28 h-28 mx-auto rounded-full bg-purple-600 overflow-hidden">
          {profileImage ? (
            <img src={URL.createObjectURL(profileImage)} alt="Profile" className="object-cover w-full h-full" />
          ) : profile?.profile_image_url ? (
            <img src={profile.profile_image_url} alt="Profile" className="object-cover w-full h-full" />
          ) : (
            <span className="text-4xl flex justify-center items-center h-full">👤</span>
          )}
          <input
            type="file"
            accept="image/*"
            onChange={handleImageChange}
            className="absolute inset-0 opacity-0 cursor-pointer"
          />
        </div>

        <div className="space-y-4 text-left">
          <div>
            <label className="text-sm text-gray-400">Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full p-3 rounded-xl bg-[#121212] text-white mt-1"
            />
          </div>

          <div>
            <label className="text-sm text-gray-400">Age</label>
            <input
              type="number"
              value={age}
              onChange={(e) => setAge(e.target.value)}
              className="w-full p-3 rounded-xl bg-[#121212] text-white mt-1"
            />
          </div>

          <div>
            <label className="text-sm text-gray-400">Gender</label>
            <select
              value={gender}
              onChange={(e) => setGender(e.target.value)}
              className="w-full p-3 h-6 rounded-xl bg-[#121212] text-white mt-1"
            >
              <option>Male</option>
              <option>Female</option>
              <option>Other</option>
            </select>
          </div>
        </div>

        <button
          onClick={handleSave}
          className="w-full bg-purple-600 hover:bg-purple-700 py-3 rounded-xl font-semibold"
        >
          Save Changes
        </button>
      </div>
    </div>
  );
}

export default EditProfile;
