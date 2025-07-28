/*
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import haloImg from '../assets/halo.jpg';
import hubImg from '../assets/hub.jpg';
import ivyImg from '../assets/ivy.jpg';
import houseLogo from '../assets/house-logo.png';

const images = [haloImg, hubImg, ivyImg];

function Landing() {
  const navigate = useNavigate();
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrent((prev) => (prev + 1) % images.length);
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="relative min-h-screen bg-black text-white flex items-center justify-center overflow-hidden">
      
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

      
      <div className="absolute inset-0 bg-black/80 z-10" />

      
      <div className="relative z-20 text-center max-w-2xl px-6 space-y-6">
        <img src={houseLogo} alt="LeaseLink" className="w-24 h-24 mx-auto" />

        <h1 className="text-4xl md:text-5xl font-extrabold">
          Your <span className="text-purple-500">Student Housing</span> Solution
        </h1>
        <p className="text-gray-300 text-lg">
          Subleasing made effortless. Affordable. Community-first.
        </p>

        <button
          onClick={() => navigate('/auth')}
          className="px-8 py-3 bg-purple-600 hover:bg-purple-700 rounded-xl text-lg font-semibold shadow-md shadow-purple-900/40 transition"
        >
          Get Started
        </button>
      </div>
    </div>
  );
}

export default Landing;
*/

import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import haloImg from '../assets/halo.jpg';
import houseLogo from '../assets/house-logo.png';
import hubImg from '../assets/hub.jpg';
import ivyImg from '../assets/ivy.jpg';

const images = [haloImg, hubImg, ivyImg];

function Landing() {
  const navigate = useNavigate();
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrent((prev) => (prev + 1) % images.length);
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  return (
    //<div className="bg-gradient-to-br from-black via-[#1e1e1e] to-[#121212] min-h-screen text-white flex items-center justify-center">
    <div className="bg-black min-h-screen text-white flex items-center justify-center">
  
      <div className="max-w-5xl mx-auto px-6 grid md:grid-cols-2 gap-10 items-center">
        {/* Left: Logo & Text */}
        <div className="space-y-6">
          <img src={houseLogo} alt="LeaseLink" className="w-20 h-20" />

          <h1 className="text-5xl font-extrabold text-white leading-tight">
            Your <span className="text-purple-500">Student Housing</span> Solution
          </h1>

          <p className="text-gray-400 text-lg">
            Discover, sublease, and manage apartments with ease.  
            Designed for students, by students. Hassle-free. Affordable. Instant.
          </p>

          <div className="flex flex-col sm:flex-row gap-4">
            <button
              onClick={() => navigate('/auth')}
              className="px-8 py-3 bg-purple-600 hover:bg-purple-700 rounded-xl text-lg font-semibold shadow-md shadow-purple-900/50 transition"
            >
              Get Started
            </button>
            
            <button
              onClick={() => navigate('/waitlist')}
              className="px-8 py-3 bg-white/10 hover:bg-white/20 border border-white/20 rounded-xl text-lg font-semibold transition"
            >
              Join Waitlist
            </button>
          </div>
        </div>

        {/* Right: Slideshow */}
        <div className="hidden md:block">
          <div className="relative rounded-2xl overflow-hidden shadow-2xl h-96">
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

export default Landing;
