#!/bin/bash

echo "🧪 Testing PEP Analysis after environment variables fix..."

# Test PEP Analysis
echo ""
echo "📤 Sending PEP analysis request..."

RESPONSE=$(curl -s -X POST https://text-doc-api-service-369455734154.asia-southeast2.run.app/api/analyze-text/pep-analysis \
  -H 'Content-Type: application/json' \
  -d '{"name": "Juhana S.E.", "entity_type": "person"}')

echo "📥 Response:"
echo "$RESPONSE" | jq '.'

# Extract job_id for status check
JOB_ID=$(echo "$RESPONSE" | jq -r '.job_id')

if [ "$JOB_ID" != "null" ] && [ -n "$JOB_ID" ]; then
    echo ""
    echo "⏳ Waiting 10 seconds for processing..."
    sleep 10
    
    echo ""
    echo "📋 Checking job status..."
    
    STATUS_RESPONSE=$(curl -s https://text-doc-api-service-369455734154.asia-southeast2.run.app/api/status/$JOB_ID)
    echo "$STATUS_RESPONSE" | jq '.'
    
    # Check if job completed successfully
    STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
    ERROR=$(echo "$STATUS_RESPONSE" | jq -r '.error')
    
    if [ "$STATUS" = "completed" ]; then
        echo ""
        echo "✅ SUCCESS! PEP analysis completed successfully!"
        echo "🎉 Bug has been fixed!"
    elif [ "$STATUS" = "failed" ]; then
        echo ""
        echo "❌ FAILED: $ERROR"
        echo "🔍 Need to investigate further..."
    else
        echo ""
        echo "⏳ Job is still processing (status: $STATUS)"
        echo "💡 Try checking status again in a few minutes"
    fi
else
    echo ""
    echo "❌ Failed to submit job. Response:"
    echo "$RESPONSE"
fi