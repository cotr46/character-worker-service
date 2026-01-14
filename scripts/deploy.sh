#!/bin/bash

# Deployment script for Text Analysis Services
# Run this from the root directory of your project

echo "🚀 Starting deployment of Text Analysis services..."

# Set project and region
PROJECT_ID="bni-prod-dma-bnimove-ai"
REGION="asia-southeast2"

echo "📋 Project: $PROJECT_ID"
echo "📍 Region: $REGION"

# Deploy API Service
echo ""
echo "🔄 Deploying API Service..."
gcloud run services replace api_service/api_service.yaml \
  --region=$REGION \
  --project=$PROJECT_ID

if [ $? -eq 0 ]; then
    echo "✅ API Service deployed successfully"
else
    echo "❌ API Service deployment failed"
    exit 1
fi

# Deploy Worker Service
echo ""
echo "🔄 Deploying Worker Service..."
gcloud run services replace worker_service/worker_service.yaml \
  --region=$REGION \
  --project=$PROJECT_ID

if [ $? -eq 0 ]; then
    echo "✅ Worker Service deployed successfully"
else
    echo "❌ Worker Service deployment failed"
    exit 1
fi

echo ""
echo "🎉 All services deployed successfully!"
echo ""
echo "📊 Service URLs:"
echo "   API Service: https://text-doc-api-service-369455734154.asia-southeast2.run.app"
echo "   Worker Service: https://text-doc-worker-service-369455734154.asia-southeast2.run.app"
echo ""
echo "🧪 Test the PEP analysis with:"
echo "curl -X POST https://text-doc-api-service-369455734154.asia-southeast2.run.app/api/analyze-text/pep-analysis \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"name\": \"Juhana S.E.\", \"entity_type\": \"person\"}'"