import React, { useState, useEffect } from 'react';
import { API_URL } from '../config';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalOrders: 0,
    totalUsers: 0,
    activeProducts: 0,
    totalSales: 0
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const res = await fetch(`${API_URL}/admin/stats`);
      const data = await res.json();
      if (data) {
        setStats({
          totalOrders: data.totalOrders || 0,
          totalUsers: data.totalUsers || 0,
          activeProducts: data.activeProducts || 0,
          totalSales: data.totalSales || 0
        });
      }
    } catch (err) {
      console.error('Error fetching stats:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div>Loading dashboard...</div>;
  }

  return (
    <div>
      <h2 className="page-title">Dashboard Overview</h2>
      
      <div className="dashboard-grid">
        <div className="glass-panel stat-card">
          <div className="stat-title">Total Orders</div>
          <div className="stat-value">{stats.totalOrders}</div>
        </div>
        
        <div className="glass-panel stat-card">
          <div className="stat-title">Active Products</div>
          <div className="stat-value">{stats.activeProducts}</div>
        </div>
        
        <div className="glass-panel stat-card">
          <div className="stat-title">Total Users</div>
          <div className="stat-value">{stats.totalUsers}</div>
        </div>

        <div className="glass-panel stat-card">
          <div className="stat-title">Revenue</div>
          <div className="stat-value">₹{stats.totalSales}</div>
        </div>
      </div>

      <div className="glass-panel" style={{ padding: '24px', minHeight: '300px' }}>
        <h3 style={{ marginTop: 0 }}>Recent Activity</h3>
        <p style={{ color: 'var(--text-secondary)' }}>System running smoothly. No new alerts.</p>
      </div>
    </div>
  );
};

export default Dashboard;