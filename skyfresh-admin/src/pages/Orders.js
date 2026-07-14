import React, { useState, useEffect } from 'react';

const API_BASE = 'http://localhost:5000/api';

const STATUS_META = {
  placed:            { label: 'Placed',           bg: '#DBEAFE', color: '#1D4ED8' },
  confirmed:         { label: 'Confirmed',        bg: '#EDE9FE', color: '#7C3AED' },
  out_for_delivery:  { label: 'Out for Delivery', bg: '#FFEDD5', color: '#EA580C' },
  delivered:         { label: 'Delivered',        bg: '#DCFCE7', color: '#16A34A' },
  cancelled:         { label: 'Cancelled',        bg: '#FEE2E2', color: '#DC2626' },
};

const STATUS_TABS = ['All', 'placed', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'];

function formatDate(iso) {
  const d = new Date(iso);
  return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
}

function itemsSummary(items) {
  return items.map(i => `${i.name}${i.quantity > 1 ? ` x${i.quantity}` : ''}`).join(', ');
}

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState('All');
  const [updatingId, setUpdatingId] = useState(null);

  const fetchOrders = async () => {
    setLoading(true);
    setError('');
    try {
      const res = await fetch(`${API_BASE}/orders`);
      const data = await res.json();
      if (data.success) {
        setOrders(data.orders);
      } else {
        setError(data.message || 'Could not load orders');
      }
    } catch (e) {
      setError('Cannot connect to server. Is the backend running?');
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  const filtered = filter === 'All' ? orders : orders.filter(o => o.status === filter);

  const updateStatus = async (id, status) => {
    setUpdatingId(id);
    const prevOrders = orders;
    setOrders(orders.map(o => o._id === id ? { ...o, status } : o));

    try {
      const res = await fetch(`${API_BASE}/orders/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      });
      const data = await res.json();
      if (!data.success) {
        setOrders(prevOrders);
        alert(data.message || 'Could not update status');
      }
    } catch (e) {
      setOrders(prevOrders);
      alert('Cannot connect to server.');
    }
    setUpdatingId(null);
  };

  const countByStatus = (status) => orders.filter(o => o.status === status).length;

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>Orders 📦</h1>
          <p style={styles.sub}>{orders.length} total orders</p>
        </div>
        <div style={styles.summaryRow}>
          <div style={styles.summaryBadge('#DCFCE7', '#16A34A')}>
            ✅ {countByStatus('delivered')} Delivered
          </div>
          <div style={styles.summaryBadge('#DBEAFE', '#1D4ED8')}>
            📦 {countByStatus('placed')} Placed
          </div>
          <div style={styles.summaryBadge('#FFEDD5', '#EA580C')}>
            🛵 {countByStatus('out_for_delivery')} Out for Delivery
          </div>
        </div>
      </div>

      <div style={styles.tabs}>
        {STATUS_TABS.map(f => (
          <button key={f} style={{
            ...styles.tab,
            background: filter === f ? 'linear-gradient(90deg, #15803D, #22C55E)' : '#fff',
            color: filter === f ? '#fff' : '#64748B',
            boxShadow: filter === f ? '0 4px 12px rgba(21,128,61,0.3)' : 'none',
          }} onClick={() => setFilter(f)}>
            {f === 'All' ? 'All' : STATUS_META[f].label}
          </button>
        ))}
        <button style={styles.refreshBtn} onClick={fetchOrders} disabled={loading}>
          {loading ? 'Refreshing…' : '↻ Refresh'}
        </button>
      </div>

      <div style={styles.card}>
        {loading ? (
          <div style={styles.centerMsg}>Loading orders…</div>
        ) : error ? (
          <div style={{ ...styles.centerMsg, color: '#DC2626' }}>{error}</div>
        ) : filtered.length === 0 ? (
          <div style={styles.centerMsg}>No orders found.</div>
        ) : (
          <table style={styles.table}>
            <thead>
              <tr>
                {['Customer', 'Phone', 'Items', 'Address', 'Total', 'Date', 'Status', 'Update'].map(h => (
                  <th key={h} style={styles.th}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map(o => (
                <tr key={o._id} style={styles.tr}>
                  <td style={{ ...styles.td, fontWeight: 700 }}>{o.user?.name || 'Unknown'}</td>
                  <td style={styles.td}>{o.user?.phone || '—'}</td>
                  <td style={styles.td}>{itemsSummary(o.items)}</td>
                  <td style={{ ...styles.td, maxWidth: 180, color: '#64748B' }}>{o.address}</td>
                  <td style={{ ...styles.td, fontWeight: 700 }}>₹{o.total}</td>
                  <td style={{ ...styles.td, color: '#94A3B8' }}>{formatDate(o.createdAt)}</td>
                  <td style={styles.td}>
                    <span style={{
                      ...styles.badge,
                      background: STATUS_META[o.status]?.bg || '#F1F5F9',
                      color: STATUS_META[o.status]?.color || '#64748B',
                    }}>
                      {STATUS_META[o.status]?.label || o.status}
                    </span>
                  </td>
                  <td style={styles.td}>
                    <select
                      value={o.status}
                      disabled={updatingId === o._id}
                      onChange={e => updateStatus(o._id, e.target.value)}
                      style={styles.select}>
                      <option value="placed">Placed</option>
                      <option value="confirmed">Confirmed</option>
                      <option value="out_for_delivery">Out for Delivery</option>
                      <option value="delivered">Delivered</option>
                      <option value="cancelled">Cancelled</option>
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

const styles = {
  page: { padding: 28 },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 20 },
  title: { fontSize: 26, fontWeight: 800, color: '#0C1A2E' },
  sub: { fontSize: 13, color: '#94A3B8', marginTop: 4 },
  summaryRow: { display: 'flex', gap: 10 },
  summaryBadge: (bg, color) => ({ background: bg, color, padding: '8px 14px', borderRadius: 20, fontSize: 12, fontWeight: 700 }),
  tabs: { display: 'flex', gap: 8, marginBottom: 20, alignItems: 'center' },
  tab: { padding: '8px 20px', borderRadius: 20, border: 'none', fontSize: 13, fontWeight: 600, cursor: 'pointer' },
  refreshBtn: { marginLeft: 'auto', padding: '8px 16px', borderRadius: 20, border: '1.5px solid #E2E8F0', background: '#fff', color: '#15803D', fontSize: 13, fontWeight: 700, cursor: 'pointer' },
  card: { background: '#fff', borderRadius: 18, padding: 20, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  centerMsg: { padding: '40px 0', textAlign: 'center', color: '#94A3B8', fontSize: 14 },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', fontSize: 12, color: '#94A3B8', fontWeight: 600, paddingBottom: 12, borderBottom: '2px solid #F1F5F9' },
  tr: { borderBottom: '1px solid #F8FAFC' },
  td: { padding: '12px 4px', fontSize: 13, color: '#0C1A2E' },
  badge: { padding: '4px 12px', borderRadius: 20, fontSize: 11, fontWeight: 700 },
  select: { padding: '6px 10px', border: '1.5px solid #E2E8F0', borderRadius: 8, fontSize: 12, cursor: 'pointer', outline: 'none' },
};