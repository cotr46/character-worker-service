#!/bin/bash

# Check Pub/Sub Configuration Script
echo "🔍 Checking Pub/Sub Configuration..."
echo "=================================="

PROJECT_ID="bni-prod-dma-bnimove-ai"
TOPIC="document-processing-request"
SUBSCRIPTION="document-processing-worker"
REGION="asia-southeast2"

echo "📋 Project: $PROJECT_ID"
echo "📋 Topic: $TOPIC"
echo "📋 Subscription: $SUBSCRIPTION"
echo "📋 Region: $REGION"
echo ""

# Check if topic exists
echo "🔍 Checking topic..."
gcloud pubsub topics describe $TOPIC --project=$PROJECT_ID 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Topic exists"
else
    echo "❌ Topic does not exist"
fi
echo ""

# Check if subscription exists
echo "🔍 Checking subscription..."
gcloud pubsub subscriptions describe $SUBSCRIPTION --project=$PROJECT_ID 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Subscription exists"
    
    # Get subscription details
    echo ""
    echo "📋 Subscription details:"
    gcloud pubsub subscriptions describe $SUBSCRIPTION --project=$PROJECT_ID --format="table(
        name,
        pushConfig.pushEndpoint,
        ackDeadlineSeconds,
        messageRetentionDuration
    )"
    
    # Check push endpoint
    PUSH_ENDPOINT=$(gcloud pubsub subscriptions describe $SUBSCRIPTION --project=$PROJECT_ID --format="value(pushConfig.pushEndpoint)")
    if [ -n "$PUSH_ENDPOINT" ]; then
        echo ""
        echo "🔗 Push endpoint: $PUSH_ENDPOINT"
        
        # Test push endpoint
        echo "🧪 Testing push endpoint health..."
        curl -s -o /dev/null -w "%{http_code}" "$PUSH_ENDPOINT" | grep -q "200\|404\|405"
        if [ $? -eq 0 ]; then
            echo "✅ Push endpoint is reachable"
        else
            echo "❌ Push endpoint is not reachable"
        fi
    else
        echo "⚠️ No push endpoint configured (pull subscription)"
    fi
    
else
    echo "❌ Subscription does not exist"
fi
echo ""

# Get Worker Service URL
echo "🔍 Getting Worker Service URL..."
WORKER_URL=$(gcloud run services describe document-processing-text-analysis-worker \
  --region=$REGION \
  --project=$PROJECT_ID \
  --format="value(status.url)" 2>/dev/null)

if [ -n "$WORKER_URL" ]; then
    echo "✅ Worker Service URL: $WORKER_URL"
    
    # Test worker health
    echo "🧪 Testing worker health..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$WORKER_URL/health")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Worker service is healthy"
    else
        echo "❌ Worker service health check failed (HTTP $HTTP_CODE)"
    fi
    
    # Check if push endpoint matches worker URL
    EXPECTED_PUSH_ENDPOINT="$WORKER_URL/pubsub/push"
    if [ "$PUSH_ENDPOINT" = "$EXPECTED_PUSH_ENDPOINT" ]; then
        echo "✅ Push endpoint matches worker service"
    else
        echo "❌ Push endpoint mismatch!"
        echo "   Expected: $EXPECTED_PUSH_ENDPOINT"
        echo "   Actual: $PUSH_ENDPOINT"
        
        echo ""
        echo "🔧 To fix, run:"
        echo "gcloud pubsub subscriptions modify-push-config $SUBSCRIPTION \\"
        echo "  --push-endpoint=\"$EXPECTED_PUSH_ENDPOINT\" \\"
        echo "  --project=$PROJECT_ID"
    fi
else
    echo "❌ Worker Service not found"
fi
echo ""

# Check recent messages
echo "🔍 Checking recent Pub/Sub metrics..."
gcloud pubsub subscriptions describe $SUBSCRIPTION --project=$PROJECT_ID --format="table(
    name,
    numUndeliveredMessages,
    pushConfig.pushEndpoint
)" 2>/dev/null

echo ""
echo "🏁 Pub/Sub configuration check completed"