document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('waitlistForm');
    const submitBtn = document.querySelector('.submit-btn');
    const btnText = document.querySelector('.btn-text');
    const loadingSpinner = document.querySelector('.loading-spinner');
    const successMessage = document.getElementById('successMessage');
    const errorMessage = document.getElementById('errorMessage');

    // Google Apps Script Web App URL
    const GOOGLE_APPS_SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbz0CNoZGCzMZROCoBbC0AxRRf9dLuk1nZf68ChDLP2hjm_HhgK9Y4aqcGk5azfqnncxDg/exec';

    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        // Show loading state
        submitBtn.disabled = true;
        btnText.style.display = 'none';
        loadingSpinner.style.display = 'flex';
        
        // Hide any existing messages
        successMessage.style.display = 'none';
        errorMessage.style.display = 'none';

        // Get form data
        const formData = new FormData(form);
        const data = {
            email: formData.get('email'),
            timestamp: new Date().toISOString()
        };

        try {
            // Send data to Google Apps Script
            const response = await fetch(GOOGLE_APPS_SCRIPT_URL, {
                method: 'POST',
                mode: 'cors',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                // Success
                form.style.display = 'none';
                successMessage.style.display = 'block';
                
                // Optional: Track conversion with Google Analytics
                if (typeof gtag !== 'undefined') {
                    gtag('event', 'waitlist_signup', {
                        'event_category': 'engagement'
                    });
                }
            } else {
                throw new Error('Failed to submit form');
            }
        } catch (error) {
            console.error('Error submitting form:', error);
            
            // Show error message
            errorMessage.style.display = 'block';
            
            // Reset button state
            submitBtn.disabled = false;
            btnText.style.display = 'block';
            loadingSpinner.style.display = 'none';
        }
    });

    // Form validation
    const emailInput = document.getElementById('email');
    
    emailInput.addEventListener('blur', function() {
        validateEmail(this);
    });
    
    emailInput.addEventListener('input', function() {
        if (this.classList.contains('error')) {
            validateEmail(this);
        }
    });

    function validateEmail(field) {
        const value = field.value.trim();
        
        // Remove existing error styling
        field.classList.remove('error');
        
        // Email validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value)) {
            field.classList.add('error');
            showFieldError(field, 'Please enter a valid email address');
            return false;
        } else {
            hideFieldError(field);
            return true;
        }
    }

    function showFieldError(field, message) {
        // Remove existing error message
        hideFieldError(field);
        
        // Create error message element
        const errorDiv = document.createElement('div');
        errorDiv.className = 'field-error';
        errorDiv.textContent = message;
        errorDiv.style.cssText = `
            color: #ef4444;
            font-size: 12px;
            margin-top: 4px;
            text-align: left;
        `;
        
        field.parentNode.appendChild(errorDiv);
    }

    function hideFieldError(field) {
        const existingError = field.parentNode.querySelector('.field-error');
        if (existingError) {
            existingError.remove();
        }
    }

    // Add error styling to CSS
    const style = document.createElement('style');
    style.textContent = `
        input.error {
            border-color: #ef4444 !important;
            background: rgba(239, 68, 68, 0.1) !important;
        }
    `;
    document.head.appendChild(style);
}); 
