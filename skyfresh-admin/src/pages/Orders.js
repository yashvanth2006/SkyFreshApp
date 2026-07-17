import React, { useState, useEffect } from 'react';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const API_URL = 'http://localhost:5000/api/orders';

  // Fetch all live customer orders across the platform
  const fetchOrders = async () => {
    try {
      setLoading(true);
      const response = await fetch(API_URL);
      const data = await response.json();
      if (data.success) {
        setOrders(data.orders);
      } else {
        setError(data.message);
      }
    } catch (err) {
      setError('Could not connect to the backend server to fetch orders.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  // Handle changing an order's fulfillment tracking status
  const handleStatusChange = async (orderId, newStatus) => {
    try {
      const response = await fetch(`${API_URL}/${orderId}/status`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: newStatus }),
      });
      const data = await response.json();

      if (data.success) {
        // Update local state smoothly
        setOrders(orders.map(order => 
          order._id === orderId ? { ...order, status: newStatus } : order
        ));
        alert(`Status updated to: ${newStatus.replace(/_/g, ' ')} 🚚`);
      } else {
        alert(`Failed to update status: ${data.message}`);
      }
    } catch (err) {
      alert('Error updating status on backend.');
    }
  };

  // Helper function to color code badges based on delivery state
  const getStatusStyle = (status) => {
    switch (status) {
      case 'placed': return { bg: '#e3f2fd', color: '#0d47a1' };
      case 'confirmed': return { bg: '#fff3e0', color: '#e65100' };
      case 'out_for_delivery': return { bg: '#f3e5f5', color: '#4a148c' };
      case 'delivered': return { bg: '#e8f5e9', color: '#1b5e20' };
      case 'cancelled': return { bg: '#ffebee', color: '#b71c1c' };
      default: return { bg: '#f5f5f5', color: '#333' };
    }
  };

  if (loading) return <div style={{ padding: '20px' }}>Loading incoming orders pipeline...</div>;
  if (error) return <div style={{ padding: '20px', color: 'red' }}>❌ Error: {error}</div>;

  return (
    <div style={{ padding: '20px' }}>
      <h2>Live Customer Orders Pipeline</h2>
      <h3>Active Batches ({orders.length} orders total)</h3>

      {orders.length === 0 ? (
        <div style={{ padding: '40px', textAlign: 'center', background: '#f9f9f9', borderRadius: '8px', border: '1px dashed #ccc' }}>
          🛒 No orders have been placed on the platform yet.
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          {orders.map(order => {
            const badge = getStatusStyle(order.status);
            return (
              <div key={order._id} style={{ border: '1px solid #ddd', borderRadius: '8px', padding: '20px', background: '#fff', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
                
                {/* Header Row */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #eee', paddingBottom: '10px', marginBottom: '15px' }}>
                  <div>
                    <span style={{ fontWeight: 'bold', fontSize: '1.1rem' }}>Order ID: #{order._id.slice(-6).toUpperCase()}</span>
                    <span style={{ marginLeft: '15px', color: '#666', fontSize: '0.9rem' }}>
                      {new Date(order.createdAt).toLocaleString()}
                    </span>
                  </div>
                  <div>
                    <span style={{ backgroundColor: badge.bg, color: badge.color, padding: '6px 12px', borderRadius: '20px', fontWeight: 'bold', fontSize: '0.85rem', textTransform: 'uppercase' }}>
                      {order.status.replace(/_/g, ' ')}
                    </span>
                  </div>
                </div>

                {/* Content Layout Grid */}
                <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '20px' }}>
                  
                  {/* Left Column: Items Purchased */}
                  <div>
                    <h4 style={{ margin: '0 0 10px 0', color: '#555' }}>Items Ordered</h4>
                    <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
                      {order.items.map((item, index) => (
                        <li key={index} style={{ padding: '6px 0', borderBottom: '1px dashed #f0f0f0', display: 'flex', justifyContent: 'space-between' }}>
                          <span>{item.emoji} {item.name} <span style={{ color: '#777' }}>x{item.quantity}</span></span>
                          <span style={{ fontWeight: '500' }}>₹{item.price * item.quantity}</span>
                        </li>
                      ))}
                    </ul>
                    <div style={{ marginTop: '10px', textAlign: 'right', fontWeight: 'bold', fontSize: '1.1rem' }}>
                      Total Bill: <span style={{ color: '#2e7d32' }}>₹{order.total}</span>
                    </div>
                  </div>

                  {/* Right Column: Customer Details & Fulfillment Controls */}
                  <div style={{ borderLeft: '1px solid #eee', paddingLeft: '20px' }}>
                    <h4 style={{ margin: '0 0 5px 0', color: '#555' }}>Customer Info</h4>
                    <p style={{ margin: '0 0 5px 0', fontWeight: '500' }}>{order.user?.name || 'Guest User'}</p>
                    <p style={{ margin: '0 0 15px 0', color: '#666', fontSize: '0.9rem' }}>📞 {order.user?.phone || 'N/A'}</p>

                    <h4 style={{ margin: '0 0 5px 0', color: '#555' }}>Delivery Destination</h4>
                    <p style={{ margin: '0 0 20px 0', fontSize: '0.9rem', color: '#444', lineHeight: '1.4' }}>📍 {order.address}</p>

                    <h4 style={{ margin: '0 0 8px 0', color: '#555' }}>Dispatch Management</h4>
                    <select 
                      value={order.status} 
                      onChange={(e) => handleStatusChange(order._id, e.target.value)}
                      style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #ccc', background: '#fafafa', cursor: 'pointer', fontWeight: '500' }}
                    >
                      <option value="placed">Placed (Pending Review)</option>
                      <option value="confirmed">Confirm Order</option>
                      <option value="out_for_delivery">Out For Delivery 🛵</option>
                      <option value="delivered">Mark as Delivered ✅</option>
                      <option value="cancelled">Cancel Order ❌</option>
                    </select>
                  </div>

                </div>

              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default Orders;