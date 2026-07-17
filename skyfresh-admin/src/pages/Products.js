import React, { useState, useEffect } from 'react';

const Products = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Form State
  const [name, setName] = useState('');
  const [price, setPrice] = useState('');
  const [unit, setUnit] = useState('1 kg');
  const [emoji, setEmoji] = useState('🍎');
  const [category, setCategory] = useState('Fruits');
  const [stock, setStock] = useState(50);
  const [color, setColor] = useState('#FFF3CD');

  const API_URL = 'http://localhost:5000/api/products';
  
  // Custom headers including token verification
  const getAdminHeaders = () => {
    const token = localStorage.getItem('adminToken');
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

  // Handle adding a new product to the database
  const handleAddProduct = async (e) => {
    e.preventDefault();
    const newProduct = { name, price: Number(price), unit, emoji, category, stock: Number(stock), color };

    try {
      const response = await fetch(`${API_URL}/add`, {
        method: 'POST',
        headers: getAdminHeaders(),
        body: JSON.stringify(newProduct),
      });
      const data = await response.json();

      if (data.success) {
        setProducts([...products, data.product]);
        // Reset dynamic form elements
        setName('');
        setPrice('');
        alert('🌿 Product added to catalog successfully!');
      } else {
        alert(`Failed to add product: ${data.message}`);
      }
    } catch (err) {
      alert('Error connecting to backend.');
    }
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
      
      {/* Add Product Form */}
      <form onSubmit={handleAddProduct} style={{ background: '#f4f4f4', padding: '20px', borderRadius: '8px', marginBottom: '30px' }}>
        <h3>Add New Fresh Item</h3>
        <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
          <input type="text" placeholder="Product Name" value={name} onChange={e => setName(e.target.value)} required style={{ padding: '8px', flex: 1 }} />
          <input type="number" placeholder="Price (₹)" value={price} onChange={e => setPrice(e.target.value)} required style={{ padding: '8px', width: '120px' }} />
          <input type="text" placeholder="Unit (e.g. 1 kg)" value={unit} onChange={e => setUnit(e.target.value)} required style={{ padding: '8px', width: '120px' }} />
        </div>
        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <input type="text" placeholder="Emoji (e.g. 🍉)" value={emoji} onChange={e => setEmoji(e.target.value)} required style={{ padding: '8px', width: '100px' }} />
          <input type="number" placeholder="Stock Qty" value={stock} onChange={e => setStock(e.target.value)} required style={{ padding: '8px', width: '100px' }} />
          <input type="color" value={color} onChange={e => setColor(e.target.value)} style={{ width: '50px', height: '38px', padding: '0', border: 'none' }} title="Choose background highlight color" />
          
          <select value={category} onChange={e => setCategory(e.target.value)} style={{ padding: '8px' }}>
            <option value="Fruits">Fruits</option>
            <option value="Juices">Juices</option>
            <option value="Fresh Cuts">Fresh Cuts</option>
          </select>
          <button type="submit" style={{ padding: '8px 20px', background: '#2e7d32', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>Save Product</button>
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
                <td style={{ padding: '12px' }}>
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