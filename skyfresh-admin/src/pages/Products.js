import React, { useState } from 'react';

const initialProducts = [
  { id: 1, name: 'Fresh Mango',       price: 60,  unit: '250g',  emoji: '🥭', category: 'Fruits',     stock: 50 },
  { id: 2, name: 'Watermelon',        price: 40,  unit: '500g',  emoji: '🍉', category: 'Fresh Cuts', stock: 30 },
  { id: 3, name: 'Orange Juice',      price: 80,  unit: '300ml', emoji: '🍊', category: 'Juices',     stock: 25 },
  { id: 4, name: 'Fresh Apple',       price: 50,  unit: '200g',  emoji: '🍎', category: 'Fruits',     stock: 40 },
  { id: 5, name: 'Mango Juice',       price: 90,  unit: '300ml', emoji: '🥭', category: 'Juices',     stock: 20 },
  { id: 6, name: 'Pineapple',         price: 70,  unit: '300g',  emoji: '🍍', category: 'Fruits',     stock: 35 },
  { id: 7, name: 'Green Juice',       price: 100, unit: '300ml', emoji: '🥬', category: 'Juices',     stock: 15 },
  { id: 8, name: 'Mixed Fruit Bowl',  price: 120, unit: '400g',  emoji: '🍱', category: 'Fresh Cuts', stock: 20 },
];

export default function Products() {
  const [products, setProducts] = useState(initialProducts);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ name: '', price: '', unit: '', emoji: '', category: 'Fruits', stock: '' });

  const handleAdd = () => {
    if (!form.name || !form.price) return;
    setProducts([...products, { ...form, id: Date.now(), price: Number(form.price), stock: Number(form.stock) }]);
    setForm({ name: '', price: '', unit: '', emoji: '', category: 'Fruits', stock: '' });
    setShowForm(false);
  };

  const handleDelete = (id) => {
    setProducts(products.filter(p => p.id !== id));
  };

  return (
    <div style={styles.page}>
      {/* Header */}
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>Products 🍎</h1>
          <p style={styles.sub}>{products.length} products in catalog</p>
        </div>
        <button style={styles.addBtn} onClick={() => setShowForm(!showForm)}>
          + Add Product
        </button>
      </div>

      {/* Add form */}
      {showForm && (
        <div style={styles.form}>
          <h3 style={{ marginBottom: 16, color: '#0C1A2E' }}>Add New Product</h3>
          <div style={styles.formGrid}>
            <input style={styles.input} placeholder="Product name"
              value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} />
            <input style={styles.input} placeholder="Emoji (e.g. 🍊)"
              value={form.emoji} onChange={e => setForm({ ...form, emoji: e.target.value })} />
            <input style={styles.input} placeholder="Price (₹)"
              type="number" value={form.price}
              onChange={e => setForm({ ...form, price: e.target.value })} />
            <input style={styles.input} placeholder="Unit (e.g. 250g)"
              value={form.unit} onChange={e => setForm({ ...form, unit: e.target.value })} />
            <select style={styles.input} value={form.category}
              onChange={e => setForm({ ...form, category: e.target.value })}>
              <option>Fruits</option>
              <option>Juices</option>
              <option>Fresh Cuts</option>
            </select>
            <input style={styles.input} placeholder="Stock quantity"
              type="number" value={form.stock}
              onChange={e => setForm({ ...form, stock: e.target.value })} />
          </div>
          <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
            <button style={styles.saveBtn} onClick={handleAdd}>Save Product</button>
            <button style={styles.cancelBtn} onClick={() => setShowForm(false)}>Cancel</button>
          </div>
        </div>
      )}

      {/* Products table */}
      <div style={styles.card}>
        <table style={styles.table}>
          <thead>
            <tr>
              {['Product', 'Category', 'Price', 'Unit', 'Stock', 'Actions'].map(h => (
                <th key={h} style={styles.th}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {products.map(p => (
              <tr key={p.id} style={styles.tr}>
                <td style={styles.td}>
                  <div style={styles.productCell}>
                    <span style={styles.emoji}>{p.emoji}</span>
                    <span style={{ fontWeight: 600 }}>{p.name}</span>
                  </div>
                </td>
                <td style={styles.td}>
                  <span style={styles.catBadge}>{p.category}</span>
                </td>
                <td style={styles.td}>₹{p.price}</td>
                <td style={styles.td}>{p.unit}</td>
                <td style={styles.td}>
                  <span style={{
                    ...styles.stockBadge,
                    background: p.stock > 20 ? '#DCFCE7' : '#FEF9C3',
                    color: p.stock > 20 ? '#16A34A' : '#CA8A04',
                  }}>
                    {p.stock} left
                  </span>
                </td>
                <td style={styles.td}>
                  <button style={styles.deleteBtn}
                    onClick={() => handleDelete(p.id)}>
                    🗑️ Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

const styles = {
  page: { padding: 28 },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 },
  title: { fontSize: 26, fontWeight: 800, color: '#0C1A2E' },
  sub: { fontSize: 13, color: '#94A3B8', marginTop: 4 },
  addBtn: { background: 'linear-gradient(90deg, #0EA5E9, #38BDF8)', color: '#fff', border: 'none', padding: '10px 20px', borderRadius: 12, fontSize: 14, fontWeight: 700, cursor: 'pointer' },
  form: { background: '#fff', borderRadius: 18, padding: 24, marginBottom: 20, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  formGrid: { display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 },
  input: { padding: '10px 14px', border: '1.5px solid #E2E8F0', borderRadius: 10, fontSize: 13, outline: 'none', width: '100%' },
  saveBtn: { background: 'linear-gradient(90deg, #16A34A, #22C55E)', color: '#fff', border: 'none', padding: '10px 24px', borderRadius: 10, fontWeight: 700, cursor: 'pointer' },
  cancelBtn: { background: '#F1F5F9', color: '#64748B', border: 'none', padding: '10px 24px', borderRadius: 10, fontWeight: 700, cursor: 'pointer' },
  card: { background: '#fff', borderRadius: 18, padding: 20, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', fontSize: 12, color: '#94A3B8', fontWeight: 600, paddingBottom: 12, borderBottom: '2px solid #F1F5F9' },
  tr: { borderBottom: '1px solid #F8FAFC' },
  td: { padding: '12px 0', fontSize: 13, color: '#0C1A2E' },
  productCell: { display: 'flex', alignItems: 'center', gap: 10 },
  emoji: { fontSize: 24, background: '#F8FAFC', padding: 6, borderRadius: 8 },
  catBadge: { background: '#E0F2FE', color: '#0284C7', padding: '3px 10px', borderRadius: 20, fontSize: 11, fontWeight: 600 },
  stockBadge: { padding: '3px 10px', borderRadius: 20, fontSize: 11, fontWeight: 700 },
  deleteBtn: { background: '#FEF2F2', color: '#EF4444', border: 'none', padding: '6px 12px', borderRadius: 8, fontSize: 12, cursor: 'pointer', fontWeight: 600 },
};