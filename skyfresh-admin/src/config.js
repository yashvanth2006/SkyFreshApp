// Configuration file for SKYfresh Admin Panel
// Update these values based on your environment

const config = {
  // API Base URL - Change this to match your backend server
  // For local development: http://localhost:5000/api
  // For production: https://your-domain.com/api
  API_BASE_URL: process.env.REACT_APP_API_URL || 'http://localhost:5000/api',
  
  // Other configuration options can be added here
  APP_NAME: 'SKYfresh Admin',
  VERSION: '1.0.0'
};

export default config;
