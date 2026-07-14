import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const stats = [
  { label: 'Total Users',    value: '1,240', icon: '👥', color: '#0EA5E9', bg: '#F0F9FF' },
  { label: 'Total Orders',   value: '856',   icon: '📦', color: '#16A34A', bg: '#F0FDF4' },
  { label: 'Total Products', value: '48',    icon: '🍎', color: '#F97316', bg: '#FFF7ED' },
  { label: 'Revenue',        value: '₹84,200', icon: '💰', color: '#7C3AED', bg: '#FAF5FF' },
];

const chartData = [
  { day: 'Mon', orders: 40 },
  { day: 'Tue', orders: 65 },
  { day: 'Wed', orders: 50 },
  { day: 'Thu', orders: 80 },
  { day: 'Fri', orders: 95 },
  { day: 'Sat', orders: 110 },
  { day: 'Sun', orders: 75 },
];

const recentOrders = [
  { id: '#001', customer: 'Yashvanth', items: 'Mango, Orange Juice', total: '₹150', status: 'Delivered' },
  { id: '#002', customer: 'Rahul',     items: 'Apple, Green Juice',  total: '₹180', status: 'Pending'   },
  { id: '#003', customer: 'Priya',     items: 'Watermelon',          total: '₹40',  status: 'Delivered' },
  { id: '#004', customer: 'Karthik',   items: 'Mixed Fruit Bowl',    total: '₹120', status: 'Processing'},
];

export default function Dashboard() {
  return (
    <div style={styles.page}>
      {/* Header */}
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>Dashboard 📊</h1>
          <p style={styles.sub}>Welcome back, Admin! Here's what's happening.</p>
        </div>
        <div style={styles.dateBadge}>📅 Today, {new Date().toLocaleDateString()}</div>
      </div>

      {/* Stats */}
      <div style={styles.statsGrid}>
        {stats.map((s, i) => (
          <div key={i} style={styles.statCard}>
            <div style={{ ...styles.statIcon, background: s.bg, color: s.color }}>
              {s.icon}
            </div>
            <div>
              <div style={styles.statValue}>{s.value}</div>
              <div style={styles.statLabel}>{s.label}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={styles.row}>
        {/* Chart */}
        <div style={styles.card}>
          <h2 style={styles.cardTitle}>Orders This Week</h2>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" />
              <XAxis dataKey="day" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="orders" fill="#0EA5E9" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Recent Orders */}
        <div style={styles.card}>
          <h2 style={styles.cardTitle}>Recent Orders</h2>
          <table style={styles.table}>
            <thead>
              <tr>
                {['ID', 'Customer', 'Items', 'Total', 'Status'].map(h => (
                  <th key={h} style={styles.th}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {recentOrders.map((o, i) => (
                <tr key={i} style={styles.tr}>
                  <td style={styles.td}>{o.id}</td>
                  <td style={styles.td}>{o.customer}</td>
                  <td style={styles.td}>{o.items}</td>
                  <td style={styles.td}>{o.total}</td>
                  <td style={styles.td}>
                    <span style={{
                      ...styles.badge,
                      background: o.status === 'Delivered' ? '#DCFCE7' : 
                                  o.status === 'Pending' ? '#FEF9C3' : '#DBEAFE',
                      color: o.status === 'Delivered' ? '#16A34A' : 
                             o.status === 'Pending' ? '#CA8A04' : '#1D4ED8',
                    }}>
                      {o.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

const styles = {
  page: { padding: 28 },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 },
  title: { fontSize: 26, fontWeight: 800, color: '#0C1A2E' },
  sub: { fontSize: 13, color: '#94A3B8', marginTop: 4 },
  dateBadge: { background: '#F0F9FF', color: '#0EA5E9', padding: '8px 16px', borderRadius: 20, fontSize: 13, fontWeight: 600 },
  statsGrid: { display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginBottom: 24 },
  statCard: { background: '#fff', borderRadius: 18, padding: '20px 16px', display: 'flex', alignItems: 'center', gap: 14, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  statIcon: { width: 52, height: 52, borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, flexShrink: 0 },
  statValue: { fontSize: 22, fontWeight: 800, color: '#0C1A2E' },
  statLabel: { fontSize: 12, color: '#94A3B8', marginTop: 2 },
  row: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20 },
  card: { background: '#fff', borderRadius: 18, padding: 20, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  cardTitle: { fontSize: 16, fontWeight: 700, marginBottom: 16, color: '#0C1A2E' },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', fontSize: 12, color: '#94A3B8', fontWeight: 600, paddingBottom: 10, borderBottom: '1px solid #F1F5F9' },
  tr: { borderBottom: '1px solid #F8FAFC' },
  td: { padding: '10px 0', fontSize: 13, color: '#0C1A2E' },
  badge: { padding: '3px 10px', borderRadius: 20, fontSize: 11, fontWeight: 700 },
};