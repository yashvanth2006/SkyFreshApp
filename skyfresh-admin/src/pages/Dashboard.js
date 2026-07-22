import React from 'react';

const Dashboard = () => {
  return (
    <div>
      <h2 style={{ color: '#1e293b' }}>Dashboard Overview</h2>
      
      <div style={styles.grid}>
        <div style={styles.card}>
          <div style={styles.cardTitle}>Total Orders</div>
          <div style={styles.cardValue}>124</div>
        </div>
        
        <div style={styles.card}>
          <div style={styles.cardTitle}>Active Products</div>
          <div style={styles.cardValue}>48</div>
        </div>
        
        <div style={styles.card}>
          <div style={styles.cardTitle}>Total Users</div>
          <div style={styles.cardValue}>856</div>
        </div>

        <div style={styles.card}>
          <div style={styles.cardTitle}>Revenue</div>
          <div style={styles.cardValue}>$12,450</div>
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
  grid: { 
    display: 'grid', 
    gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
    gap: '20px', 
    marginBottom: '30px' 
  },
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