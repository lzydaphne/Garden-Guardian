const { logger, https } = require("firebase-functions/v2");
const {
  Firestore,
  FieldValue,
} =  require("@google-cloud/firestore");

const db = new Firestore();
const userCollection = db.collection('user');

exports.storeInDatabase = https.onCall(async (req) => {
  try {
    const { role, text, base64ImageUrl, timeStamp, imageDescription, embeddings } = req.data;

    logger.log('Received request to store in database', { role, text, base64ImageUrl, timeStamp, imageDescription });

    if (!embeddings || !Array.isArray(embeddings)) {
      logger.warn('Embeddings not provided or invalid', embeddings);
      throw new https.HttpsError('invalid-argument', 'Embeddings not provided or invalid');
    }

    await userCollection.add({
      role: role || 'user',
      text: text || '',
      base64ImageUrl: base64ImageUrl || '',
      timeStamp: timeStamp || new Date().toISOString(),
      imageDescription: imageDescription || '',
      embedding_field: FieldValue.vector(embeddings),
    });

    logger.log('Data stored successfully in Firestore', { role, text });

    return { success: true, message: 'Data stored successfully' };
  } catch (error) {
    logger.error("storeInDatabase: Error processing HTTP request", error);
    throw new https.HttpsError("internal", "Internal server error.");
  }
});

exports.vectorSearch = https.onCall(async (req) => {
  try {
    const { queryEmbedding, limit, distanceMeasure } = req.data;

    logger.log('Received request for vector search', { queryEmbedding, limit, distanceMeasure });

    if (!queryEmbedding || !Array.isArray(queryEmbedding)) {
      logger.warn('Query embedding not provided or invalid', queryEmbedding);
      throw new https.HttpsError('invalid-argument', 'Query embedding not provided or invalid');
    }

    const vectorQuery = userCollection.findNearest('embedding_field', FieldValue.vector(queryEmbedding), {
      limit: limit || 5,
      distanceMeasure: distanceMeasure || 'EUCLIDEAN',
    });

    const vectorQuerySnapshot = await vectorQuery.get();

    if (vectorQuerySnapshot.empty) {
      logger.warn('No similar embeddings found', { queryEmbedding });
      throw new https.HttpsError('not-found', 'No similar embeddings found');
    }

    const results = [];
    vectorQuerySnapshot.forEach(doc => {
      results.push(doc.data());
    });

    logger.log('Vector search results', results);

    return { success: true, data: results };
  } catch (error) {
    logger.error("vectorSearch: Error processing HTTP request", error);
    throw new https.HttpsError("internal", "Internal server error.");
  }
});
