import React, { useState, useEffect } from 'react';
import { API_URL } from '../config';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const res = await fetch(`${API_URL}/orders`);
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
      const res = await fetch(`${API_URL}/orders/${orderId}/status`, {
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
      <h2 className="page-title">Customer Orders</h2>
      {loading ? (
        <p>Loading orders...</p>
      ) : (
        <div className="table-container">
          <div className="table-wrapper">
            <table className="modern-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Items</th>
                <th>Total</th>
                <th>Payment</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <tr key={order.id || order._id}>
                  <td>#{(order.id || order._id || '').toString().slice(-6).toUpperCase()}</td>
                  <td>
                     <div>{order.customerName || order.userId?.name || 'Guest User'}</div>
                     <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{order.userId?.phone || ''}</div>
                  </td>
                  <td>
                     <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                       {order.items?.map(i => `${i.name} (x${i.quantity})`).join(', ')}
                     </div>
                  </td>
                  <td style={{ fontWeight: 600 }}>₹{order.totalAmount || order.total || 0}</td>
                  <td>{order.paymentMethod || 'COD'}</td>
                  <td>
                    <span className={`badge badge-${(order.status || 'pending').toLowerCase()}`}>{order.status}</span>
                  </td>
                  <td>
                    <select
                      value={order.status}
                      onChange={(e) => handleStatusChange(order.id || order._id, e.target.value)}
                      className="status-select"
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
          </div>
        </div>
      )}
    </div>
  );
};

export default Orders;