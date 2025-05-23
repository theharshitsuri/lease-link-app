import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';
import houseLogo from '../assets/house-logo.png';

function Profile() {
  const navigate = useNavigate();
  const [profile, setProfile] = useState(null);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProfile = async () => {
      const { data: userData } = await supabase.auth.getUser();
      if (!userData?.user) {
        navigate('/auth');
        return;
      }

      setUser(userData.user);

      const { data: profileData } = await supabase
        .from('profiles')
        .select()
        .eq('id', userData.user.id)
        .single();

      setProfile(profileData);
      setLoading(false);
    };

    fetchProfile();
  }, [navigate]);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/auth');
  };

  const handleDeleteAccount = async () => {
    if (window.confirm('Are you sure you want to delete your account?')) {
      await supabase.from('listings').delete().eq('user_id', user.id);
      await supabase.from('profiles').delete().eq('id', user.id);
      await supabase.auth.signOut();
      navigate('/auth');
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-black text-white">
        Loading profile...
      </div>
    );
  }

  const userEmail = profile?.email || user?.email || '';
  const displayName = profile?.name || userEmail.split('@')[0];

  return (
    <div className="relative bg-black min-h-screen text-white flex items-center justify-center">
      {/* House Logo faint */}
      <img
        src={houseLogo}
        alt="LeaseLink"
        className="absolute right-10 bottom-10 opacity-10 w-64 h-64 pointer-events-none hidden md:block"
      />

      <div className="bg-[#1e1e1e] rounded-2xl p-10 shadow-xl w-full max-w-md space-y-6 text-center">
        <div className="w-28 h-28 mx-auto rounded-full bg-purple-600 flex items-center justify-center overflow-hidden">
          {profile?.profile_image_url ? (
            <img src={profile.profile_image_url} alt="Profile" className="object-cover w-full h-full" />
          ) : (
            <span className="text-4xl">👤</span>
          )}
        </div>

        <div>
          <h2 className="text-2xl font-bold">{displayName}</h2>
          <p className="text-gray-400">{userEmail}</p>
        </div>

        <div className="space-y-3">
          <button
            onClick={() => navigate('/edit-profile')}
            className="w-full bg-purple-600 hover:bg-purple-700 py-2 rounded-xl font-semibold"
          >
            Edit Profile
          </button>
          <button
            onClick={handleLogout}
            className="w-full border border-white/20 py-2 rounded-xl hover:bg-purple-700"
          >
            Logout
          </button>
          <button
            onClick={handleDeleteAccount}
            className="w-full border border-red-500 text-red-500 py-2 rounded-xl hover:bg-red-600 hover:text-white"
          >
            Delete Account
          </button>
        </div>
      </div>
    </div>
  );
}

export default Profile;
