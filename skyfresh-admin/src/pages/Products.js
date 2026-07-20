import React, { useState, useEffect } from 'react';
import config from '../config';

const Products = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Form State
  const [editingId, setEditingId] = useState(null); // Tracks if we are editing
  const [name, setName] = useState('');
  const [price, setPrice] = useState('');
  const [unit, setUnit] = useState('');
  const [emoji, setEmoji] = useState('');
  const [category, setCategory] = useState('');
  const [stock, setStock] = useState('');
  const [color, setColor] = useState('#FFF3CD');
  const [customCategory, setCustomCategory] = useState('');
  const [useCustomCategory, setUseCustomCategory] = useState(false);

  const API_URL = `${config.API_BASE_URL}/products`;
  
  // Custom headers including token verification
  const getAdminHeaders = () => {
    const token = localStorage.getItem('adminToken');
    console.log('Products - Token from localStorage:', token ? 'exists' : 'null');
    console.log('Products - Token length:', token ? token.length : 0);
    return {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    };
  };

  // Fetch all live products from the MongoDB database
  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await fetch(API_URL);
      const data = await response.json();
      if (data.success) {
        setProducts(data.products);
      } else {
        setError(data.message);
      }
    } catch (err) {
      setError('Could not connect to the backend server.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts();
  }, []);

  // Helper to reset the form
  const resetForm = () => {
    setEditingId(null);
    setName('');
    setPrice('');
    setUnit('');
    setEmoji('');
    setCategory('');
    setStock('');
    setColor('#FFF3CD');
    setCustomCategory('');
    setUseCustomCategory(false);
  };

  // Handle adding or updating a product
  const handleSubmit = async (e) => {
    e.preventDefault();
    const finalCategory = useCustomCategory ? customCategory : category;
    const productData = { name, price: Number(price), unit, emoji, category: finalCategory, stock: Number(stock), color };

    console.log('handleSubmit - API URL:', API_URL);
    console.log('handleSubmit - editingId:', editingId);
    console.log('handleSubmit - productData:', productData);

    if (editingId) {
      // UPDATE EXISTING PRODUCT (PUT)
      try {
        const response = await fetch(`${API_URL}/${editingId}`, {
          method: 'PUT',
          headers: getAdminHeaders(),
          body: JSON.stringify(productData),
        });
        const data = await response.json();

        if (data.success) {
          setProducts(products.map(p => p._id === editingId ? data.product : p));
          resetForm();
          alert('🌿 Product updated successfully!');
        } else {
          alert(`Failed to update product: ${data.message}`);
        }
      } catch (err) {
        alert('Error connecting to backend.');
      }
    } else {
      // ADD NEW PRODUCT (POST)
      try {
        console.log('handleSubmit - Adding new product to:', `${API_URL}/add`);
        const response = await fetch(`${API_URL}/add`, {
          method: 'POST',
          headers: getAdminHeaders(),
          body: JSON.stringify(productData),
        });
        const data = await response.json();

        if (data.success) {
          setProducts([...products, data.product]);
          resetForm();
          alert('🌿 Product added to catalog successfully!');
        } else {
          alert(`Failed to add product: ${data.message}`);
        }
      } catch (err) {
        alert('Error connecting to backend.');
      }
    }
  };

  // Populate form with product data when "Edit" is clicked
  const handleEditClick = (product) => {
    setEditingId(product._id);
    setName(product.name);
    setPrice(product.price);
    setUnit(product.unit);
    setEmoji(product.emoji);
    setCategory(product.category);
    setStock(product.stock);
    setColor(product.color || '#FFF3CD');
    setCustomCategory('');
    setUseCustomCategory(false);
  };

  // Handle removing a product from the database
  const handleDeleteProduct = async (id) => {
    if (!window.confirm('Are you sure you want to remove this item from the catalog?')) return;

    try {
      const response = await fetch(`${API_URL}/${id}`, {
        method: 'DELETE',
        headers: getAdminHeaders(),
      });
      const data = await response.json();

      if (data.success) {
        setProducts(products.filter(p => p._id !== id));
      } else {
        alert(`Failed to delete: ${data.message}`);
      }
    } catch (err) {
      alert('Error connecting to backend.');
    }
  };

  if (loading) return <div style={{ padding: '20px' }}>Loading live product catalog...</div>;
  if (error) return <div style={{ padding: '20px', color: 'red' }}>❌ Error: {error}</div>;

  return (
    <div style={{ padding: '20px' }}>
      <h2>Inventory Management Dashboard</h2>
      
      {/* Add / Update Product Form */}
      <form onSubmit={handleSubmit} style={{ background: '#f4f4f4', padding: '20px', borderRadius: '8px', marginBottom: '30px' }}>
        <h3>{editingId ? 'Edit Product' : 'Add New Fresh Item'}</h3>
        <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
          <input type="text" placeholder="Product Name" value={name} onChange={e => setName(e.target.value)} required style={{ padding: '8px', flex: 1 }} />
          <input type="number" placeholder="Price (₹)" value={price} onChange={e => setPrice(e.target.value)} required style={{ padding: '8px', width: '120px' }} />
          <input type="text" placeholder="Unit (e.g. 1 kg)" value={unit} onChange={e => setUnit(e.target.value)} required style={{ padding: '8px', width: '120px' }} />
        </div>
        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <input type="text" placeholder="Emoji (e.g. 🍉)" value={emoji} onChange={e => setEmoji(e.target.value)} required style={{ padding: '8px', width: '100px' }} />
          <input type="number" placeholder="Stock Qty" value={stock} onChange={e => setStock(e.target.value)} required style={{ padding: '8px', width: '100px' }} />
          <input type="color" value={color} onChange={e => setColor(e.target.value)} style={{ width: '50px', height: '38px', padding: '0', border: 'none' }} title="Choose background highlight color" />
          
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <select 
              value={useCustomCategory ? 'custom' : category} 
              onChange={e => {
                if (e.target.value === 'custom') {
                  setUseCustomCategory(true);
                  setCategory('');
                } else {
                  setUseCustomCategory(false);
                  setCategory(e.target.value);
                }
              }} 
              style={{ padding: '8px' }}
              disabled={useCustomCategory}
            >
              <option value="">Select Category</option>
              <option value="Fruits">Fruits</option>
              <option value="Vegetables">Vegetables</option>
              <option value="Dairy & Eggs">Dairy & Eggs</option>
              <option value="Meat & Poultry">Meat & Poultry</option>
              <option value="Bakery">Bakery</option>
              <option value="Snacks">Snacks</option>
              <option value="Beverages">Beverages</option>
              <option value="Pasta & Grains">Pasta & Grains</option>
              <option value="Others">Others</option>
              <option value="custom">Custom Category...</option>
            </select>
            
            {useCustomCategory && (
              <input 
                type="text" 
                placeholder="Enter custom category" 
                value={customCategory} 
                onChange={e => setCustomCategory(e.target.value)} 
                required 
                style={{ padding: '8px', flex: 1 }} 
              />
            )}
          </div>
          
          <button type="submit" style={{ padding: '8px 20px', background: editingId ? '#1976d2' : '#2e7d32', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
            {editingId ? 'Update Product' : 'Save Product'}
          </button>
          
          {/* Show a Cancel button if we are in edit mode */}
          {editingId && (
            <button type="button" onClick={resetForm} style={{ padding: '8px 20px', background: '#757575', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
              Cancel
            </button>
          )}
        </div>
      </form>

      {/* Products Table Data View */}
      <div>
        <h3>Current Catalog ({products.length} items)</h3>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
          <thead>
            <tr style={{ background: '#e0e0e0' }}>
              <th style={{ padding: '12px' }}>Item</th>
              <th style={{ padding: '12px' }}>Category</th>
              <th style={{ padding: '12px' }}>Price</th>
              <th style={{ padding: '12px' }}>Stock Status</th>
              <th style={{ padding: '12px' }}>Action</th>
            </tr>
          </thead>
          <tbody>
            {products.map(product => (
              <tr key={product._id} style={{ borderBottom: '1px solid #ddd' }}>
                <td style={{ padding: '12px' }}>
                  <span style={{ marginRight: '8px', padding: '4px 8px', borderRadius: '4px', background: product.color || '#fff' }}>{product.emoji}</span> 
                  {product.name} ({product.unit})
                </td>
                <td style={{ padding: '12px' }}>{product.category}</td>
                <td style={{ padding: '12px' }}>₹{product.price}</td>
                <td style={{ padding: '12px' }}>{product.stock} units</td>
                <td style={{ padding: '12px', display: 'flex', gap: '8px' }}>
                  <button onClick={() => handleEditClick(product)} style={{ background: '#1976d2', color: 'white', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer' }}>Edit</button>
                  <button onClick={() => handleDeleteProduct(product._id)} style={{ background: '#d32f2f', color: 'white', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer' }}>Remove</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Products;