import React, { useState, useEffect } from 'react';
import config from '../config'; // Updated to '../config'

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const res = await fetch(`${config.API_BASE_URL}/orders`);
      const data = await res.json();
      setOrders(data);
    } catch (err) {
      console.error('Error fetching orders:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (orderId, newStatus) => {
    try {
      const res = await fetch(`${config.API_BASE_URL}/orders/${orderId}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus })
      });

      if (res.ok) {
        setOrders(
          orders.map((order) =>
            (order.id === orderId || order._id === orderId) ? { ...order, status: newStatus } : order
          )
        );
      }
    } catch (err) {
      console.error('Error updating status:', err);
    }
  };

  return (
    <div>
      <h2>Customer Orders</h2>
      {loading ? (
        <p>Loading orders...</p>
      ) : (
        <table style={styles.table}>
          <thead>
            <tr>
              <th style={styles.th}>Order ID</th>
              <th style={styles.th}>Customer</th>
              <th style={styles.th}>Total</th>
              <th style={styles.th}>Status</th>
              <th style={styles.th}>Action</th>
            </tr>
          </thead>
          <tbody>
            {orders.map((order) => (
              <tr key={order.id || order._id}>
                <td style={styles.td}>#{(order.id || order._id).slice(-6)}</td>
                <td style={styles.td}>{order.customerName || order.user || 'Guest User'}</td>
                <td style={styles.td}>${order.totalAmount || order.total || 0}</td>
                <td style={styles.td}>
                  <span style={getBadgeStyle(order.status)}>{order.status}</span>
                </td>
                <td style={styles.td}>
                  <select
                    value={order.status}
                    onChange={(e) => handleStatusChange(order.id || order._id, e.target.value)}
                    style={styles.select}
                  >
                    <option value="Pending">Pending</option>
                    <option value="Processing">Processing</option>
                    <option value="Shipped">Shipped</option>
                    <option value="Delivered">Delivered</option>
                    <option value="Cancelled">Cancelled</option>
                  </select>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

const getBadgeStyle = (status) => {
  let bg = '#e2e8f0';
  let color = '#334155';
  if (status === 'Delivered') { bg = '#dcfce7'; color = '#15803d'; }
  if (status === 'Pending') { bg = '#fef9c3'; color = '#a16207'; }
  if (status === 'Shipped') { bg = '#dbeafe'; color = '#1d4ed8'; }
  if (status === 'Cancelled') { bg = '#fee2e2'; color = '#b91c1c'; }

  return {
    padding: '4px 10px',
    borderRadius: '12px',
    fontSize: '0.85rem',
    fontWeight: '600',
    backgroundColor: bg,
    color: color
  };
};

const styles = {
  table: { width: '100%', borderCollapse: 'collapse', backgroundColor: '#fff', borderRadius: '8px', overflow: 'hidden', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' },
  th: { padding: '12px 16px', textAlign: 'left', backgroundColor: '#f1f5f9', borderBottom: '1px solid #e2e8f0' },
  td: { padding: '12px 16px', borderBottom: '1px solid #e2e8f0' },
  select: { padding: '6px 10px', borderRadius: '4px', border: '1px solid #cbd5e1' }
};

export default Orders;