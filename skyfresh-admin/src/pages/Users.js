import React, { useState, useEffect } from 'react';
import { API_URL } from '../config';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const res = await fetch(`${API_URL}/users`);
      const data = await res.json();
      setUsers(data);
    } catch (err) {
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h2 className="page-title">User Management</h2>
      {loading ? (
        <p>Loading user list...</p>
      ) : (
        <div className="table-container">
          <div className="table-wrapper">
            <table className="modern-table">
            <thead>
              <tr>
                <th>User ID</th>
                <th>Name</th>
                <th>Phone</th>
                <th>Registered</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id || user._id}>
                  <td>#{(user.id || user._id || '').toString().slice(-6).toUpperCase()}</td>
                  <td>{user.name || 'N/A'}</td>
                  <td>{user.phone || 'N/A'}</td>
                  <td style={{ color: 'var(--text-secondary)' }}>
                    {user.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'N/A'}
                  </td>
                  <td>
                    <span className={`badge ${user.isVerified ? 'badge-delivered' : 'badge-pending'}`}>
                      {user.isVerified ? 'Verified' : 'Pending'}
                    </span>
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

export default Users;