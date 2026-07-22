import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';

// Updated paths to match your folder structure
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import Products from './pages/Products';
import Orders from './pages/Orders';
import Users from './Users'; // This one is still in the root src folder

function App() {
  return (
    <Router>
      <div className="admin-container" style={{ display: 'flex', minHeight: '100vh' }}>
        <Sidebar />
        <main className="main-content" style={{ flex: 1, padding: '24px', backgroundColor: '#f8fafc' }}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/products" element={<Products />} />
            <Route path="/orders" element={<Orders />} />
            <Route path="/users" element={<Users />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;