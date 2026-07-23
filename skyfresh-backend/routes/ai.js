const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const { GoogleGenAI } = require('@google/genai');

// Verify API key and initialize Gemini AI
if (!process.env.GEMINI_API_KEY) {
  console.warn('\x1b[33m%s\x1b[0m', '⚠️  WARNING: GEMINI_API_KEY is not set in .env file. AI features will not work properly.');
}

// Initialize the NEW SDK correctly
const ai = process.env.GEMINI_API_KEY 
  ? new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY })
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

    // Check if API key is available
    if (!ai) {
      return res.status(500).json({
        success: false,
        message: 'AI service is not configured. Please add GEMINI_API_KEY to environment variables.'
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

    // Use real AI with proper guardrails
    try {
      const prompt = `You are a friendly Smart Nutritionist for the SkyFresh app, a fresh fruit and juice delivery service.

CONVERSATIONAL: If the user says "hello", "hi", "how are you", or similar greetings, respond naturally and warmly.

MEDICAL GUARDRAILS (CRITICAL): 
- If the user mentions serious illnesses (e.g., cancer, diabetes, heart disease, hypertension, kidney disease, liver disease, autoimmune disorders, etc.), you MUST state that you are NOT a doctor.
- Advise them to consult a medical professional for proper medical advice.
- Kindly explain that you can only recommend general healthy fruits from our inventory, not medical treatments.

CONTEXT: Here is our current inventory in JSON format:
${JSON.stringify(productList, null, 2)}

The user asked: "${query}"

Reply with a JSON object containing exactly these two fields:
1. "message" - a short, friendly response (2-3 sentences) explaining your recommendation or greeting
2. "recommendedProductIds" - an array of the MongoDB _ids (as strings) of the best matching products from our inventory. Return an empty array [] if no products match or if the query is just a greeting.

IMPORTANT: Only recommend items from the provided inventory list. Return ONLY valid JSON, no additional text or markdown formatting.`;

      // Call the AI using the new SDK syntax and the active 2026 model
      const result = await ai.models.generateContent({
        model: 'gemini-3.6-flash',
        contents: prompt,
        config: {
          responseMimeType: "application/json"
        }
      });
      
      // The new SDK uses .text instead of .text()
      let rawText = result.text;
      
      // Remove markdown code blocks if present
      rawText = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
      
      // Parse AI response
      let aiResponse;
      try {
        aiResponse = JSON.parse(rawText);
      } catch (parseError) {
        console.error('Failed to parse AI response as JSON:', rawText);
        throw new Error('Invalid AI response format');
      }

      // Validate response structure
      if (!aiResponse.message || !Array.isArray(aiResponse.recommendedProductIds)) {
        throw new Error('AI response missing required fields');
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

    } catch (aiError) {
      console.error('AI Route Error:', aiError.message, aiError);
      return res.status(500).json({
        success: false,
        message: 'AI Error: ' + aiError.message,
        recommendedProducts: []
      });
    }

  } catch (err) {
    console.error('AI Route Error:', err.message, err);
    res.status(500).json({ 
      success: false, 
      message: 'AI Error: ' + err.message,
      recommendedProducts: []
    });
  }
});

module.exports = router;