import React, { useState, useEffect } from 'react';
import { API_URL } from '../config';

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
      const res = await fetch(`${API_URL}/products?_t=${Date.now()}`);
      const data = await res.json();
      console.log('Fetched data:', data);
      
      // Handle array response
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
      ? `${API_URL}/products/${formData.id || formData._id}`
      : `${API_URL}/products`;
    const method = isEditing ? 'PUT' : 'POST';

    try {
      const res = await fetch(url, {
        method,
        headers: getAdminHeaders(),
        body: JSON.stringify(formData)
      });

      if (res.ok) {
        await fetchProducts();
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
      const res = await fetch(`${API_URL}/products/${id}`, {
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
      <h2 className="page-title">Product Catalog Management</h2>
      
      {/* Product Form */}
      <form onSubmit={handleSubmit} className="glass-panel form-container">
        <h3 className="form-title">{isEditing ? 'Edit Product' : 'Add New Product'}</h3>
        <div className="product-form-group">
          <input
            type="text"
            name="name"
            placeholder="Product Name"
            value={formData.name}
            onChange={handleChange}
            required
            className="form-input"
          />
          <input
            type="number"
            name="price"
            placeholder="Price (₹)"
            value={formData.price}
            onChange={handleChange}
            required
            className="form-input"
          />
          <input
            type="text"
            name="unit"
            placeholder="Unit (e.g., 1kg, 500ml, 1 pc)"
            value={formData.unit}
            onChange={handleChange}
            required
            className="form-input"
          />
          
          {/* UPDATED: Category Dropdown */}
          <select
            name="category"
            value={formData.category}
            onChange={handleChange}
            required
            className="form-input"
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
            className="form-input"
          />
          <input
            type="text"
            name="image"
            placeholder="Image URL (optional - auto-filled if empty)"
            value={formData.image}
            onChange={handleChange}
            className="form-input"
          />
        </div>
        <div style={{ marginTop: '20px', display: 'flex', gap: '12px' }}>
          <button type="submit" className="btn btn-primary">
            {isEditing ? 'Update Product' : 'Save Product'}
          </button>
          {isEditing && (
            <button type="button" onClick={resetForm} className="btn btn-secondary">
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
        <div className="table-container">
          <div className="table-wrapper">
            <table className="modern-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {products.map((p) => (
                <tr key={p.id || p._id}>
                  <td>{p.name}</td>
                  <td>{p.category}</td>
                  <td>₹{p.price} / {p.unit}</td>
                  <td>{p.stock}</td>
                  <td style={{ display: 'flex', gap: '8px' }}>
                    <button onClick={() => handleEdit(p)} className="btn btn-primary btn-small">
                      Edit
                    </button>
                    <button
                      onClick={() => handleDeleteProduct(p.id || p._id)}
                      className="btn btn-danger btn-small"
                    >
                      Remove
                    </button>
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

export default Products;