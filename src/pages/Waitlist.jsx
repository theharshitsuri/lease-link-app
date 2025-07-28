import { useState } from 'react';
import houseLogo from '../assets/house-logo.png';

function Waitlist() {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      const response = await fetch('https://script.google.com/macros/s/AKfycbz0CNoZGCzMZROCoBbC0AxRRf9dLuk1nZf68ChDLP2hjm_HhgK9Y4aqcGk5azfqnncxDg/exec', {
        method: 'POST',
        mode: 'cors',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: email,
          timestamp: new Date().toISOString()
        })
      });

      console.log('Response status:', response.status);
      console.log('Response headers:', response.headers);

      if (response.ok) {
        const result = await response.json();
        console.log('Response data:', result);
        
        if (result.result === 'success') {
          setIsSuccess(true);
          setEmail('');
        } else {
          throw new Error(result.error || 'Unknown error occurred');
        }
      } else {
        const errorText = await response.text();
        console.error('Error response:', errorText);
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }
    } catch (error) {
      console.error('Error submitting form:', error);
      
      // Provide more specific error messages
      if (error.name === 'TypeError' && error.message.includes('Failed to fetch')) {
        setError('Network error. Please check your internet connection and try again.');
      } else if (error.message.includes('CORS')) {
        setError('CORS error. The server needs to be updated to allow requests from localhost.');
      } else {
        setError(`Something went wrong: ${error.message}`);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  if (isSuccess) {
    return (
      <div className="min-h-screen bg-black text-white flex items-center justify-center px-6">
        <div className="max-w-md w-full text-center space-y-6">
          <div className="w-16 h-16 bg-green-500/20 rounded-full flex items-center justify-center mx-auto">
            <svg className="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
            </svg>
          </div>
          
          <h2 className="text-2xl font-bold text-white">You're on the list!</h2>
          <p className="text-gray-400">We'll notify you when LeaseLink launches.</p>
          
          <button
            onClick={() => setIsSuccess(false)}
            className="px-6 py-2 bg-purple-600 hover:bg-purple-700 rounded-lg text-sm font-medium transition"
          >
            Join another email
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black text-white flex items-center justify-center px-6">
      <div className="max-w-md w-full">
        {/* Logo and Title */}
        <div className="text-center mb-8">
          <div className="flex justify-center mb-6">
            <img src={houseLogo} alt="LeaseLink" className="w-16 h-16" />
          </div>
          
          <h1 className="text-3xl font-bold text-white mb-2">LeaseLink</h1>
          <p className="text-gray-400">Your student-friendly sublease marketplace</p>
        </div>

        {/* Waitlist Form */}
        <div className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-xl p-8">
          <h2 className="text-xl font-semibold text-white mb-2 text-center">Join the waitlist</h2>
          <p className="text-gray-400 text-sm text-center mb-6">Be the first to know when we launch</p>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter your email"
                required
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:border-purple-500 focus:bg-purple-500/10 transition"
              />
            </div>
            
            <button
              type="submit"
              disabled={isLoading || !validateEmail(email)}
              className="w-full px-4 py-3 bg-purple-600 hover:bg-purple-700 disabled:bg-gray-600 disabled:cursor-not-allowed rounded-lg font-medium transition flex items-center justify-center"
            >
              {isLoading ? (
                <>
                  <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin mr-2"></div>
                  Joining...
                </>
              ) : (
                'Join waitlist'
              )}
            </button>
          </form>

          {error && (
            <div className="mt-4 p-3 bg-red-500/10 border border-red-500/20 rounded-lg">
              <p className="text-red-400 text-sm text-center">{error}</p>
              <p className="text-red-400 text-xs text-center mt-1">
                Check the browser console for more details
              </p>
            </div>
          )}
        </div>

        {/* Features */}
        <div className="mt-8 grid grid-cols-1 gap-4">
          <div className="bg-white/5 border border-white/10 rounded-lg p-4 text-center">
            <div className="text-2xl mb-2">🏠</div>
            <h3 className="font-medium text-white mb-1">Student-Friendly</h3>
            <p className="text-gray-400 text-sm">Designed specifically for students by students</p>
          </div>
          
          <div className="bg-white/5 border border-white/10 rounded-lg p-4 text-center">
            <div className="text-2xl mb-2">🔒</div>
            <h3 className="font-medium text-white mb-1">Secure & Trusted</h3>
            <p className="text-gray-400 text-sm">Verified listings and secure transactions</p>
          </div>
          
          <div className="bg-white/5 border border-white/10 rounded-lg p-4 text-center">
            <div className="text-2xl mb-2">⚡</div>
            <h3 className="font-medium text-white mb-1">Quick & Easy</h3>
            <p className="text-gray-400 text-sm">Find or list a sublease in minutes</p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Waitlist; 