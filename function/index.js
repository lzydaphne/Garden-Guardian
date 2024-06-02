exports.storeInDatabase = functions.https.onRequest(async (req, res) => {
    try {
      const { role, text, base64ImageUrl, timeStamp, imageDescription, embeddings } = req.body;
  
      if (!embeddings || !Array.isArray(embeddings)) {
        res.status(400).send('Embeddings not provided or invalid');
        return;
      }
  
      await coll.add({
        role: role || 'user',
        text: text || '',
        base64ImageUrl: base64ImageUrl || '',
        timeStamp: timeStamp || new Date().toISOString(),
        imageDescription: imageDescription || '',
        embedding_field: FieldValue.vector(embeddings),
      });
  
      res.status(200).send('Chat message and embeddings stored successfully');
    } catch (error) {
      console.error('Error storing chat message and embeddings:', error);
      res.status(500).send('Error storing chat message and embeddings');
    }
  });
  

  exports.vectorSearch = functions.https.onRequest(async (req, res) => {
    try {
      const { queryEmbedding, limit, distanceMeasure } = req.body;
  
      if (!queryEmbedding || !Array.isArray(queryEmbedding)) {
        res.status(400).send('Query embedding not provided or invalid');
        return;
      }
  
      const vectorQuery = coll.findNearest('embedding_field', FieldValue.vector(queryEmbedding), {
        limit: limit || 5,
        distanceMeasure: distanceMeasure || 'EUCLIDEAN',
      });
  
      const vectorQuerySnapshot = await vectorQuery.get();
  
      if (vectorQuerySnapshot.empty) {
        res.status(404).send('No similar embeddings found');
        return;
      }
  
      const results = [];
      vectorQuerySnapshot.forEach(doc => {
        results.push(doc.data());
      });
  
      res.status(200).send(results);
    } catch (error) {
      console.error('Error in vector search:', error);
      res.status(500).send('Error in vector search');
    }
  });
  