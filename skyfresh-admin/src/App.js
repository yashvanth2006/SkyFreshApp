import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import Products from './pages/Products';
import Orders from './pages/Orders';

export default function App() {
  return (
    <BrowserRouter>
      <div style={styles.container}>
        <Sidebar />
        <main style={styles.main}>
          <Routes>
            <Route path="/"         element={<Dashboard />} />
            <Route path="/products" element={<Products />}  />
            <Route path="/orders"   element={<Orders />}    />
            <Route path="*"         element={<Navigate to="/" replace />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}

const styles = {
  container: {
    display: 'flex',
    minHeight: '100vh',
  },
  main: {
    marginLeft: 240,
    flex: 1,
    minHeight: '100vh',
    background: '#F8FAFC',
  },
};  