import React, { useState, useEffect } from 'react';
import config from '../config';

const getAdminHeaders = () => ({
  'Content-Type': 'application/json',
});

const Products = () => {
  const [products, setProducts] = useState([]);
  const [formData, setFormData] = useState({ id: null, name: '', price: '', unit: '', category: '', stock: '', image: '' });
  const [isEditing, setIsEditing] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const res = await fetch(`${config.API_BASE_URL}/products`);
      const data = await res.json();
      if (Array.isArray(data)) {
        setProducts(data);
      } else {
        setProducts([]);
      }
    } catch (err) {
      console.error('Error fetching products:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Prevent submitting without a category
    if (!formData.category) {
      alert("Please select a category (Fruits or Juices)!");
      return;
    }

    const url = isEditing
      ? `${config.API_BASE_URL}/products/${formData.id || formData._id}`
      : `${config.API_BASE_URL}/products`;
    const method = isEditing ? 'PUT' : 'POST';

    try {
      const res = await fetch(url, {
        method,
        headers: getAdminHeaders(),
        body: JSON.stringify(formData)
      });

      if (res.ok) {
        fetchProducts();
        resetForm();
        alert(isEditing ? 'Product updated successfully!' : 'Product saved successfully!');
      } else {
        // If it fails, this will read the error from the backend and show it to you
        const errorData = await res.json();
        console.error('Server error response:', errorData);
        alert(`Failed to save product: ${errorData.message || 'Check terminal for errors'}`);
      }
    } catch (err) {
      console.error('Error saving product:', err);
      alert('Network error. Make sure your Node.js backend is running!');
    }
  };

  const handleEdit = (product) => {
    setFormData(product);
    setIsEditing(true);
  };

  const handleDeleteProduct = async (id) => {
    if (!window.confirm('Are you sure you want to delete this product?')) return;
    try {
      const res = await fetch(`${config.API_BASE_URL}/products/${id}`, {
        method: 'DELETE',
        headers: getAdminHeaders()
      });
      if (res.ok) {
        fetchProducts();
      }
    } catch (err) {
      console.error('Error deleting product:', err);
    }
  };

  const resetForm = () => {
    setFormData({ id: null, name: '', price: '', unit: '', category: '', stock: '', image: '' });
    setIsEditing(false);
  };

  return (
    <div>
      <h2>Product Catalog Management</h2>
      
      {/* Product Form */}
      <form onSubmit={handleSubmit} style={styles.form}>
        <h3>{isEditing ? 'Edit Product' : 'Add New Product'}</h3>
        <div style={styles.formGroup}>
          <input
            type="text"
            name="name"
            placeholder="Product Name"
            value={formData.name}
            onChange={handleChange}
            required
            style={styles.input}
          />
          <input
            type="number"
            name="price"
            placeholder="Price (₹)"
            value={formData.price}
            onChange={handleChange}
            required
            style={styles.input}
          />
          <input
            type="text"
            name="unit"
            placeholder="Unit (e.g., 1kg, 500ml, 1 pc)"
            value={formData.unit}
            onChange={handleChange}
            required
            style={styles.input}
          />
          
          {/* UPDATED: Category Dropdown */}
          <select
            name="category"
            value={formData.category}
            onChange={handleChange}
            required
            style={styles.input}
          >
            <option value="" disabled>Select Category</option>
            <option value="Fruits">Fruits</option>
            <option value="Juices">Juices</option>
          </select>

          <input
            type="number"
            name="stock"
            placeholder="Stock Quantity"
            value={formData.stock}
            onChange={handleChange}
            required
            style={styles.input}
          />
          <input
            type="text"
            name="image"
            placeholder="Image URL (optional - auto-filled if empty)"
            value={formData.image}
            onChange={handleChange}
            style={styles.input}
          />
        </div>
        <div style={{ marginTop: '16px' }}>
          <button type="submit" style={styles.btnPrimary}>
            {isEditing ? 'Update Product' : 'Save Product'}
          </button>
          {isEditing && (
            <button type="button" onClick={resetForm} style={styles.btnSecondary}>
              Cancel
            </button>
          )}
        </div>
      </form>

      {/* Inventory Table */}
      <h3>Inventory List</h3>
      {loading ? (
        <p>Loading products...</p>
      ) : (
        <table style={styles.table}>
          <thead>
            <tr>
              <th style={styles.th}>Name</th>
              <th style={styles.th}>Category</th>
              <th style={styles.th}>Price</th>
              <th style={styles.th}>Stock</th>
              <th style={styles.th}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {products.map((p) => (
              <tr key={p.id || p._id}>
                <td style={styles.td}>{p.name}</td>
                <td style={styles.td}>{p.category}</td>
                <td style={styles.td}>₹{p.price} / {p.unit}</td>
                <td style={styles.td}>{p.stock}</td>
                <td style={styles.td}>
                  <button onClick={() => handleEdit(p)} style={styles.btnSmall}>
                    Edit
                  </button>
                  <button
                    onClick={() => handleDeleteProduct(p.id || p._id)}
                    style={{ ...styles.btnSmall, backgroundColor: '#ef4444' }}
                  >
                    Remove
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

const styles = {
  form: { backgroundColor: '#fff', padding: '20px', borderRadius: '8px', marginBottom: '24px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' },
  formGroup: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '12px' },
  input: { padding: '8px 12px', border: '1px solid #cbd5e1', borderRadius: '4px', outline: 'none', backgroundColor: '#fff' },
  btnPrimary: { padding: '8px 16px', backgroundColor: '#0284c7', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', marginRight: '8px' },
  btnSecondary: { padding: '8px 16px', backgroundColor: '#64748b', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer' },
  btnSmall: { padding: '4px 8px', backgroundColor: '#0284c7', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', marginRight: '6px' },
  table: { width: '100%', borderCollapse: 'collapse', backgroundColor: '#fff', borderRadius: '8px', overflow: 'hidden', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' },
  th: { padding: '12px 16px', textAlign: 'left', backgroundColor: '#f1f5f9', borderBottom: '1px solid #e2e8f0' },
  td: { borderBottom: '1px solid #e2e8f0', padding: '12px 16px' }
};

export default Products;