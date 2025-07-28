import { LoadScript } from '@react-google-maps/api';
import { Route, Routes } from 'react-router-dom';

import Navbar from './components/Navbar';
import AddListing from './pages/AddListing';
import Auth from './pages/Auth';
import ChatList from './pages/ChatList';
import ChatScreen from './pages/ChatScreen';
import EditProfile from './pages/EditProfile';
import Favorites from './pages/Favorites';
import Home from './pages/Home';
import Landing from './pages/Landing';
import ListingDetail from './pages/ListingDetail';
import MyListings from './pages/MyListings';
import Profile from './pages/profile';
import Waitlist from './pages/Waitlist';

const GOOGLE_MAPS_API_KEY = 'AIzaSyAZS0HnAjQFZXBfj0mbDxOsSabJR4jgPZc'; 

function App() {
  return (
    <LoadScript googleMapsApiKey={GOOGLE_MAPS_API_KEY} libraries={['places']}>
      <div className="bg-[#121212] min-h-screen text-white">
        <Routes>
          <Route path="/" element={<Landing />} />         
          <Route path="/waitlist" element={<Waitlist />} />
          <Route path="/home" element={<><Navbar /><Home /></>} />
          <Route path="/listing/:id" element={<><Navbar /><ListingDetail /></>} />
          <Route path="/add" element={<><Navbar /><AddListing /></>} />
          <Route path="/auth" element={<Auth />} />   
          <Route path="/profile" element={<><Navbar /><Profile /></>} />   
          <Route path="/edit-profile" element={<><Navbar /><EditProfile /></>} />  
          <Route path="/my-listings" element={<><Navbar /><MyListings /></>} />  
          <Route path="/favorites" element={<><Navbar /><Favorites /></>} />   
          <Route path="/chatlist" element={<><Navbar /><ChatList /></>} />  
          <Route path="/chat/:chatId" element={<><Navbar /><ChatScreen /></>} />      
        </Routes>
      </div>
    </LoadScript>
  );
}

export default App;
