const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize Gemini AI
const genAI = process.env.GEMINI_API_KEY 
  ? new GoogleGenerativeAI(process.env.GEMINI_API_KEY)
  : null;

// POST /api/ai/chat - AI Nutritionist endpoint
router.post('/chat', async (req, res) => {
  try {
    const { query } = req.body;

    if (!query || query.trim() === '') {
      return res.status(400).json({ 
        success: false, 
        message: 'Query is required' 
      });
    }

    // Fetch all products from database
    const products = await Product.find({});
    
    // Create a simplified product list for the AI prompt
    const productList = products.map(p => ({
      id: p._id.toString(),
      name: p.name,
      category: p.category,
      price: p.price,
      unit: p.unit
    }));

    let aiResponse;
    
    if (genAI) {
      // Use real AI if API key is available
      try {
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        
        const prompt = `You are a helpful nutritionist for a fresh fruit and juice app called SkyFresh. The user asked: "${query}". 

Here is our current inventory in JSON format:
${JSON.stringify(productList, null, 2)}

Reply with a JSON object containing two fields:
1. "message" - a short, friendly response (2-3 sentences) explaining why certain items help with the user's condition
2. "recommendedProductIds" - an array of the MongoDB _ids (as strings) of the best matching products from our inventory that would help the user

Return ONLY valid JSON, no additional text.`;

        const result = await model.generateContent(prompt);
        const responseText = result.response.text();
        
        // Parse AI response
        const jsonMatch = responseText.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          aiResponse = JSON.parse(jsonMatch[0]);
        } else {
          throw new Error('Invalid AI response format');
        }
      } catch (aiError) {
        console.error('AI API error, using fallback:', aiError.message);
        aiResponse = generateFallbackResponse(query, products);
      }
    } else {
      // Fallback if no API key
      aiResponse = generateFallbackResponse(query, products);
    }

    // Fetch full product details for recommended IDs
    const recommendedProducts = await Product.find({
      _id: { $in: aiResponse.recommendedProductIds }
    });

    res.json({
      success: true,
      message: aiResponse.message,
      recommendedProducts
    });

  } catch (err) {
    console.error('AI route error:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to process your request' 
    });
  }
});

// Fallback response generator for when AI is unavailable
function generateFallbackResponse(query, products) {
  const queryLower = query.toLowerCase();
  let message = '';
  let recommendedIds = [];

  // Simple keyword matching for fallback
  if (queryLower.includes('cold') || queryLower.includes('sick') || queryLower.includes('flu')) {
    message = 'For cold and flu symptoms, I recommend vitamin C-rich fruits like oranges and citrus juices. These will help boost your immune system!';
    const citrusProducts = products.filter(p => 
      p.name.toLowerCase().includes('orange') || 
      p.name.toLowerCase().includes('citrus') ||
      p.category.toLowerCase().includes('juices')
    );
    recommendedIds = citrusProducts.slice(0, 2).map(p => p._id.toString());
  } else if (queryLower.includes('detox') || queryLower.includes('cleanse')) {
    message = 'A detox is great! I recommend fresh fruits and natural juices that help cleanse your system. Green juices and antioxidant-rich fruits are perfect!';
    const detoxProducts = products.filter(p => 
      p.category.toLowerCase().includes('fruits') ||
      p.category.toLowerCase().includes('juices')
    );
    recommendedIds = detoxProducts.slice(0, 2).map(p => p._id.toString());
  } else if (queryLower.includes('energy') || queryLower.includes('tired')) {
    message = 'To boost your energy, try natural fruits and fresh juices! They provide quick energy and essential nutrients without the crash.';
    const energyProducts = products.filter(p => 
      p.category.toLowerCase().includes('fruits') ||
      p.category.toLowerCase().includes('juices')
    );
    recommendedIds = energyProducts.slice(0, 2).map(p => p._id.toString());
  } else {
    message = 'Based on your query, I recommend some fresh fruits and juices from our inventory. These are packed with nutrients and perfect for a healthy lifestyle!';
    recommendedIds = products.slice(0, 2).map(p => p._id.toString());
  }

  // Fallback if no products matched
  if (recommendedIds.length === 0 && products.length > 0) {
    recommendedIds = products.slice(0, 2).map(p => p._id.toString());
  }

  return {
    message,
    recommendedProductIds: recommendedIds
  };
}

module.exports = router;
