import React, { useState } from 'react';
import { Heart, ChevronLeft, ChevronRight, ImageOff } from 'lucide-react';

function ListingCard({ listing, onFavoriteToggle, onClick }) {
  const images = listing.images || [];
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const isFavorite = listing.isFavorite;

  const hasImages = images.length > 0;
  const currentImage = hasImages ? images[currentImageIndex] : null;

  const placeholderImage = 'https://placehold.co/400x300/1e1e1e/ffffff?text=No+Image&font=roboto';

  const handlePrev = (e) => {
    e.stopPropagation();
    setCurrentImageIndex((prev) => (prev - 1 + images.length) % images.length);
  };

  const handleNext = (e) => {
    e.stopPropagation();
    setCurrentImageIndex((prev) => (prev + 1) % images.length);
  };

  return (
    <div
      onClick={onClick}
      className="bg-[#1e1e1e] rounded-xl overflow-hidden shadow-lg relative group cursor-pointer"
    >
      <div className="relative h-56 w-full">
        {currentImage ? (
          <img
            src={currentImage}
            alt="Listing"
            className="w-full h-full object-cover group-hover:scale-105 transition-transform"
          />
        ) : (
          <div className="flex flex-col items-center justify-center w-full h-full bg-[#2a2a2a] text-white text-sm">
            <ImageOff size={40} className="mb-2 text-white/60" />
            No photos available
          </div>
        )}

        {/* Favorite Toggle */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            onFavoriteToggle();
          }}
          className="absolute top-3 right-3 bg-black/50 p-2 rounded-full"
        >
          <Heart
            className={isFavorite ? 'text-red-500 fill-red-500' : 'text-white'}
            size={20}
          />
        </button>

        {/* Image Nav */}
        {hasImages && images.length > 1 && (
          <>
            <button
              onClick={handlePrev}
              className="absolute left-2 top-1/2 transform -translate-y-1/2 bg-black/50 p-2 rounded-full"
            >
              <ChevronLeft className="text-white" />
            </button>
            <button
              onClick={handleNext}
              className="absolute right-2 top-1/2 transform -translate-y-1/2 bg-black/50 p-2 rounded-full"
            >
              <ChevronRight className="text-white" />
            </button>
          </>
        )}
      </div>

      {/* Listing Details */}
      <div className="p-4">
        <h2 className="text-lg font-bold text-white truncate">{listing.title}</h2>
        <p className="text-sm text-gray-400 truncate">{listing.address || listing.location}</p>
        <p className="text-sm text-white mt-1">
          ${listing.rent}/month ·{' '}
          {listing.availableTo
            ? `${listing.availableFrom} to ${listing.availableTo}`
            : `Available from ${listing.availableFrom}`}
        </p>
      </div>
    </div>
  );
}

export default ListingCard;
