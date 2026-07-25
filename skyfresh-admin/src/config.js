const config = {
  // Points to the production backend by default, unless overriden by env variable
  API_BASE_URL: process.env.REACT_APP_API_URL || 'https://skyfreshapp.onrender.com/api' 
};

export default config;