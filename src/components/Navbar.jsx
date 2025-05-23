// === src/components/Navbar.jsx ===
import React from 'react';
import { NavLink } from 'react-router-dom';
import { Home, PlusSquare, Heart, List, User } from 'lucide-react';

function Navbar() {
  return (
    <nav className="bg-[#1a1a1a] px-6 py-4 flex items-center justify-between border-b border-purple-800">
      {/* Left: Logo */}
      <NavLink to="/" className="text-2xl font-bold text-purple-500">
        LeaseLink
      </NavLink>

      {/* Right: Navigation Links */}
      <div className="flex gap-6 text-white items-center">
        <NavLink
          to="/home"
          className={({ isActive }) =>
            `flex items-center gap-1 ${isActive ? 'text-purple-400 font-semibold' : 'hover:text-purple-300'}`
          }
        >
          <Home size={18} /> Explore
        </NavLink>

        <NavLink
          to="/add"
          className={({ isActive }) =>
            `flex items-center gap-1 ${isActive ? 'text-purple-400 font-semibold' : 'hover:text-purple-300'}`
          }
        >
          <PlusSquare size={18} /> Add
        </NavLink>

        <NavLink
          to="/my-listings"
          className={({ isActive }) =>
            `flex items-center gap-1 ${isActive ? 'text-purple-400 font-semibold' : 'hover:text-purple-300'}`
          }
        >
          <List size={18} /> My Listings
        </NavLink>

        <NavLink
          to="/favorites"
          className={({ isActive }) =>
            `flex items-center gap-1 ${isActive ? 'text-purple-400 font-semibold' : 'hover:text-purple-300'}`
          }
        >
          <Heart size={18} /> Favorites
        </NavLink>

        <NavLink
          to="/profile"
          className={({ isActive }) =>
            `flex items-center gap-1 ${isActive ? 'text-purple-400 font-semibold' : 'hover:text-purple-300'}`
          }
        >
          <User size={18} /> Profile
        </NavLink>
      </div>
    </nav>
  );
}

export default Navbar;
