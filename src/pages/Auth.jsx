/*
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';
import houseLogo from '../assets/house-logo.png';
import haloImg from '../assets/halo.jpg';
import hubImg from '../assets/hub.jpg';
import ivyImg from '../assets/ivy.jpg';

const images = [haloImg, hubImg, ivyImg];

function Auth() {
  const navigate = useNavigate();
  const [mode, setMode] = useState('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrent((prev) => (prev + 1) % images.length);
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (mode === 'signup') {
        const { error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
        alert('Check your email for verification link!');
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        navigate('/home');
      }
    } catch (error) {
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen flex items-center justify-center text-white overflow-hidden">
      
      {images.map((img, index) => (
        <img
          key={index}
          src={img}
          alt={`Slide ${index + 1}`}
          className={`absolute inset-0 w-full h-full object-cover transition-opacity duration-1000 ${
            current === index ? 'opacity-100' : 'opacity-0'
          }`}
        />
      ))}

      
      <div className="absolute inset-0 bg-black/70 z-10" />

      
      <div className="relative z-20 w-full max-w-sm text-center space-y-6">
        <img src={houseLogo} alt="LeaseLink" className="w-24 h-24 mx-auto" />
        <h1 className="text-4xl font-extrabold drop-shadow-lg">LeaseLink</h1>
        <h2 className="text-lg text-gray-300 drop-shadow-md">
          {mode === 'signup' ? 'Create an account' : 'Welcome back'}
        </h2>

        <form onSubmit={handleSubmit} className="space-y-4 text-left">
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full p-3 rounded-xl bg-black/50 text-white placeholder-gray-400 backdrop-blur-sm focus:outline-none"
            required
          />
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full p-3 rounded-xl bg-black/50 text-white placeholder-gray-400 backdrop-blur-sm focus:outline-none"
            required
          />
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-purple-600 hover:bg-purple-700 text-white py-3 rounded-xl font-semibold shadow-lg"
          >
            {loading ? 'Processing...' : mode === 'signup' ? 'Sign Up' : 'Login'}
          </button>
        </form>

        <div className="text-sm text-gray-300 drop-shadow-sm">
          {mode === 'login' ? (
            <>
              Don't have an account?
              <button className="text-purple-400 ml-1" onClick={() => setMode('signup')}>
                Register here
              </button>
            </>
          ) : (
            <>
              Already have an account?
              <button className="text-purple-400 ml-1" onClick={() => setMode('login')}>
                Login here
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default Auth;
*/
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';
import houseLogo from '../assets/house-logo.png';
import haloImg from '../assets/halo.jpg';
import hubImg from '../assets/hub.jpg';
import ivyImg from '../assets/ivy.jpg';

const images = [haloImg, hubImg, ivyImg];

function Auth() {
  const navigate = useNavigate();
  const [mode, setMode] = useState('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrent((prev) => (prev + 1) % images.length);
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (mode === 'signup') {
        const { error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
        alert('Check your email for verification link!');
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        navigate('/');
      }
    } catch (error) {
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-black min-h-screen text-white flex items-center justify-center">
      <div className="max-w-7xl mx-auto px-6 grid md:grid-cols-2 gap-10 items-center">
        
        {/* Left: Compact Auth Form */}
        <div className="space-y-6 w-full max-w-md ">
          <img src={houseLogo} alt="LeaseLink" className="w-16 h-16" />

          <div>
            <h1 className="text-4xl font-extrabold ">Welcome to LeaseLink</h1>
            <p className="text-gray-400 text-base mt-2 ">
              {mode === 'signup' ? 'Create your account' : 'Login to continue'}
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white placeholder-gray-400"
              required
            />
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full p-3 rounded-xl bg-[#1e1e1e] text-white placeholder-gray-400"
              required
            />
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-purple-600 hover:bg-purple-700 text-white py-3 rounded-xl font-semibold shadow-md"
            >
              {loading ? 'Processing...' : mode === 'signup' ? 'Sign Up' : 'Login'}
            </button>
          </form>

          <div className="text-sm text-gray-400 ... flex items-center justify-center">
            {mode === 'login' ? (
              <>
                Don&apos;t have an account?
                <button
                  className="text-purple-400 ml-1 underline"
                  onClick={() => setMode('signup')}
                >
                  Register here
                </button>
              </>
            ) : (
              <>
                Already have an account?
                <button
                  className="text-purple-400 ml-1 underline"
                  onClick={() => setMode('login')}
                >
                  Login here
                </button>
              </>
            )}
          </div>
        </div>

        {/* Right: Full-width Slideshow like Landing */}
        <div className="hidden md:block">
          <div className="relative rounded-2xl overflow-hidden shadow-2xl h-96 w-full">
            {images.map((img, index) => (
              <img
                key={index}
                src={img}
                alt={`Slide ${index + 1}`}
                className={`absolute inset-0 w-full h-full object-cover transition-opacity duration-1000 ${
                  current === index ? 'opacity-100' : 'opacity-0'
                }`}
              />
            ))}
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
          </div>
        </div>
      </div>
    </div>
  );
}

export default Auth;
