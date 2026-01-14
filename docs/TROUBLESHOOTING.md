# Job Processing Troubleshooting Guide

## Issue: Jobs Stuck in "Submitted" Status

### Root Cause
Jobs are created successfully by the API Service but never progress to "processing" or "completed" status. This indicates the Worker Service is not receiving messages from Pub/Sub.

### Solution Implemented
Added Pub/Sub push endpoint support to the Worker Service to handle HTTP POST requests from Cloud Pub/Sub.

## Changes Made

### 1. Added Pub/Sub Push Endpoint
- **File**: `worker_service/worker.py`
- **New Endpoint**: `POST /pubsub/push`
- **Purpose**: Receives HTTP POST requests from Pub/Sub push subscriptions

### 2. Updated Message Acknowledgment
- **Change**: Made acknowledgment calls safe for both pull and push messages
- **Reason**: Push messages are auto-acknowledged by Pub/Sub, pull messages need manual acknowledgment

### 3. Flexible Worker Mode
- **Default**: Push mode (HTTP endpoint)
- **Optional**: Polling mode (set `ENABLE_POLLING=true`)

## Deployment Steps

### Step 1: Update Worker Service Code
The code has been updated with the new push endpoint. Deploy the updated Worker Service:

```bash
# Build and deploy Worker Service
cd worker_service
gcloud builds submit --config cloudbuild.yaml
```

### Step 2: Configure Pub/Sub Subscription
The Pub/Sub subscription needs to be configured as a **push subscription** pointing to the Worker Service URL.

#### Check Current Subscription Type
```bash
gcloud pubsub subscriptions describe document-processing-worker --project=bni-prod-dma-bnimove-ai
```

#### If it's a Pull Subscription, Convert to Push
```bash
# Get the Worker Service URL
WORKER_URL=$(gcloud run services describe document-processing-text-analysis-worker \
  --region=asia-southeast1 \
  --project=bni-prod-dma-bnimove-ai \
  --format="value(status.url)")

# Update subscription to push mode
gcloud pubsub subscriptions modify-push-config document-processing-worker \
  --push-endpoint="${WORKER_URL}/pubsub/push" \
  --project=bni-prod-dma-bnimove-ai
```

#### If Subscription Doesn't Exist, Create It
```bash
# Get the Worker Service URL
WORKER_URL=$(gcloud run services describe document-processing-text-analysis-worker \
  --region=asia-southeast1 \
  --project=bni-prod-dma-bnimove-ai \
  --format="value(status.url)")

# Create push subscription
gcloud pubsub subscriptions create document-processing-worker \
  --topic=document-processing-request \
  --push-endpoint="${WORKER_URL}/pubsub/push" \
  --project=bni-prod-dma-bnimove-ai
```

### Step 3: Verify Configuration

#### Check Worker Service Health
```bash
curl https://[WORKER-SERVICE-URL]/health
```

#### Check Subscription Configuration
```bash
gcloud pubsub subscriptions describe document-processing-worker --project=bni-prod-dma-bnimove-ai
```

Look for:
- `pushConfig.pushEndpoint` should point to your Worker Service `/pubsub/push` endpoint
- `ackDeadlineSeconds` should be reasonable (e.g., 600 seconds)

### Step 4: Test Job Processing

#### Submit a Test Job
```bash
curl -X POST https://[API-SERVICE-URL]/api/v1/jobs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [YOUR-TOKEN]" \
  -d '{
    "document_type": "ktp",
    "gcs_path": "gs://your-bucket/test-document.pdf",
    "filename": "test-document.pdf"
  }'
```

#### Monitor Job Status
```bash
# Check job status in Firestore or via API
curl https://[API-SERVICE-URL]/api/v1/jobs/[JOB-ID]
```

#### Check Worker Service Logs
```bash
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=document-processing-text-analysis-worker" \
  --project=bni-prod-dma-bnimove-ai \
  --limit=50
```

## Common Issues and Solutions

### Issue 1: Worker Service Not Receiving Messages
**Symptoms**: No logs in Worker Service, jobs stay in "submitted" status
**Solution**: Check Pub/Sub subscription configuration

### Issue 2: Authentication Errors
**Symptoms**: 403 errors in Pub/Sub logs
**Solution**: Ensure Worker Service has proper IAM permissions

### Issue 3: Worker Service Crashes
**Symptoms**: 500 errors, service restarts
**Solution**: Check Worker Service logs for errors

### Issue 4: Messages Being Retried
**Symptoms**: Same job processed multiple times
**Solution**: Ensure Worker Service returns 200 OK for successful processing

## Monitoring Commands

### Check Pub/Sub Topic
```bash
gcloud pubsub topics describe document-processing-request --project=bni-prod-dma-bnimove-ai
```

### Check Subscription Metrics
```bash
gcloud pubsub subscriptions describe document-processing-worker --project=bni-prod-dma-bnimove-ai
```

### View Worker Service Logs
```bash
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=document-processing-text-analysis-worker" \
  --project=bni-prod-dma-bnimove-ai \
  --format="table(timestamp,severity,textPayload)" \
  --limit=20
```

### View API Service Logs
```bash
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=document-processing-text-analysis-api" \
  --project=bni-prod-dma-bnimove-ai \
  --format="table(timestamp,severity,textPayload)" \
  --limit=20
```

## Expected Flow After Fix

1. **API Service** receives document processing request
2. **API Service** creates job record in Firestore with "submitted" status
3. **API Service** publishes message to `document-processing-request` topic
4. **Pub/Sub** delivers message via HTTP POST to Worker Service `/pubsub/push` endpoint
5. **Worker Service** receives message, updates job to "processing" status
6. **Worker Service** processes document, updates job to "completed" status with results

## Verification Checklist

- [ ] Worker Service deployed with new push endpoint
- [ ] Pub/Sub subscription configured as push subscription
- [ ] Push endpoint URL points to Worker Service `/pubsub/push`
- [ ] Worker Service health check returns 200 OK
- [ ] Test job progresses from "submitted" to "processing" to "completed"
- [ ] Worker Service logs show message reception and processing
- [ ] No error messages in Pub/Sub or Cloud Run logs