// Remove the hardcoded string and read from process.env
const PEXELS_KEY = process.env.PEXELS_KEY;
require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('./models/Product');

const PEXELS_KEY = 'dHPIVC9kk0FHyUKzNNMzaAa45UWwqJ1GQTsxMbTdBKwCjsczHIbniwWg';

async function getImage(query) {
  const encodedQuery = encodeURIComponent(query);
  const res = await fetch(
    `https://api.pexels.com/v1/search?query=${encodedQuery}&per_page=3&orientation=square`,
    { headers: { Authorization: PEXELS_KEY } }
  );
  const data = await res.json();

  if (!data.photos || data.photos.length === 0) {
    console.log(`⚠️  No image found for query: "${query}"`);
    return '';
  }

  return data.photos[0]?.src?.medium || '';
}

const products = [
  { name: 'Fresh Mango',       price: 60,  unit: '250g',  emoji: '🥭', category: 'Fruits',     stock: 50, color: '#FFF3CD', query: 'mango fruit closeup' },
  { name: 'Watermelon',        price: 40,  unit: '500g',  emoji: '🍉', category: 'Fresh Cuts', stock: 30, color: '#FFE4E4', query: 'watermelon slice fruit' },
  { name: 'Orange Juice',      price: 80,  unit: '300ml', emoji: '🍊', category: 'Juices',     stock: 25, color: '#FFEDD5', query: 'orange juice glass drink' },
  { name: 'Fresh Apple',       price: 50,  unit: '200g',  emoji: '🍎', category: 'Fruits',     stock: 40, color: '#FFE4E4', query: 'red apple fruit closeup' },
  { name: 'Mango Juice',       price: 90,  unit: '300ml', emoji: '🥭', category: 'Juices',     stock: 20, color: '#FFF3CD', query: 'mango juice smoothie glass' },
  { name: 'Pineapple',         price: 70,  unit: '300g',  emoji: '🍍', category: 'Fruits',     stock: 35, color: '#FFFDE7', query: 'pineapple fruit whole' },
  { name: 'Green Juice',       price: 100, unit: '300ml', emoji: '🥬', category: 'Juices',     stock: 15, color: '#DCFCE7', query: 'green vegetable juice glass' },
  { name: 'Mixed Fruit Bowl',  price: 120, unit: '400g',  emoji: '🍱', category: 'Fresh Cuts', stock: 20, color: '#EDE9FE', query: 'mixed fruit salad bowl' },
  { name: 'Banana',            price: 30,  unit: '200g',  emoji: '🍌', category: 'Fruits',     stock: 60, color: '#FFFDE7', query: 'banana fruit bunch' },
  { name: 'Pomegranate Juice', price: 110, unit: '300ml', emoji: '🍷', category: 'Juices',     stock: 18, color: '#FFE4E4', query: 'pomegranate juice glass red' },
];

mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB connected');
    console.log('📸 Fetching images from Pexels...');

    const productsWithImages = await Promise.all(
      products.map(async (p) => {
        const image = await getImage(p.query);
        console.log(`✅ ${p.name} → ${image ? 'image fetched' : 'NO IMAGE (using emoji fallback)'}`);
        const { query, ...rest } = p;
        return { ...rest, image };
      })
    );

    await Product.deleteMany();
    await Product.insertMany(productsWithImages);
    console.log('✅ Products seeded with real images!');
    process.exit();
  })
  .catch(err => {
    console.log('❌ Error:', err);
    process.exit();
  });