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
      <h2 style={{ color: '#1e293b' }}>Dashboard Overview</h2>
      
      <div className="dashboard-grid">
        <div style={styles.card}>
          <div style={styles.cardTitle}>Total Orders</div>
          <div style={styles.cardValue}>{stats.totalOrders}</div>
        </div>
        
        <div style={styles.card}>
          <div style={styles.cardTitle}>Active Products</div>
          <div style={styles.cardValue}>{stats.activeProducts}</div>
        </div>
        
        <div style={styles.card}>
          <div style={styles.cardTitle}>Total Users</div>
          <div style={styles.cardValue}>{stats.totalUsers}</div>
        </div>

        <div style={styles.card}>
          <div style={styles.cardTitle}>Revenue</div>
          <div style={styles.cardValue}>₹{stats.totalSales}</div>
        </div>
      </div>

      <div style={styles.chartPlaceholder}>
        <h3 style={{ marginTop: 0, color: '#334155' }}>Recent Activity</h3>
        <p style={{ color: '#64748b' }}>System running smoothly. No new alerts.</p>
      </div>
    </div>
  );
};

const styles = {
  card: { 
    backgroundColor: '#fff', 
    padding: '24px', 
    borderRadius: '12px', 
    boxShadow: '0 2px 10px rgba(0,0,0,0.05)',
    border: '1px solid #e2e8f0',
    display: 'flex',
    flexDirection: 'column',
    gap: '8px'
  },
  cardTitle: { 
    color: '#64748b', 
    fontSize: '0.9rem', 
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: '0.5px'
  },
  cardValue: { 
    color: '#0f172a', 
    fontSize: '2rem', 
    fontWeight: '700' 
  },
  chartPlaceholder: {
    backgroundColor: '#fff',
    padding: '24px',
    borderRadius: '12px',
    boxShadow: '0 2px 10px rgba(0,0,0,0.05)',
    border: '1px solid #e2e8f0',
    minHeight: '300px'
  }
};

export default Dashboard;