# Document Processing & Text Analysis API Service

FastAPI-based REST API service for document processing and text-based analysis. This service handles HTTP requests, job creation, and integrates with Google Cloud services.

## 🚀 Features

### Document Processing API
- Multi-format document upload (PDF, images)
- Async job processing with real-time status tracking
- Google Cloud Storage integration
- Job status and listing endpoints

### Text Analysis API
- **Person Analysis**: PEP screening, negative news, law involvement
- **Corporate Analysis**: Corporate negative news and law involvement
- **5 Analysis Models**: 
  - `politically-exposed-person-v2`
  - `negative-news`
  - `law-involvement`
  - `negative-news-corporate`
  - `law-involvement-corporate`

## 🏗️ Architecture

```
┌─────────────────┐
│   API Service   │
│                 │
│ • REST API      │
│ • Authentication│
│ • Job Creation  │
│ • Status Tracking│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Google Cloud    │
│                 │
│ • Pub/Sub       │
│ • Firestore     │
│ • Cloud Storage │
└─────────────────┘
```

## 🛠️ Technology Stack

- **Runtime**: Python 3.13
- **Framework**: FastAPI
- **Cloud Platform**: Google Cloud Run
- **Message Queue**: Google Pub/Sub
- **Database**: Google Firestore
- **Storage**: Google Cloud Storage

## 📦 API Endpoints

### Text Analysis
```bash
# Analyze person name
POST /api/analyze-text/pep-analysis
{
  "name": "John Doe",
  "entity_type": "person"
}

# Analyze corporate name  
POST /api/analyze-text/corporate-negative-news
{
  "name": "Example Corp",
  "entity_type": "corporate"
}

# Get available models
GET /api/text-models

# Check model health
GET /api/text-models/health
```

### Document Processing
```bash
# Upload document
POST /api/upload

# Get job status
GET /api/status/{job_id}

# List jobs
GET /api/jobs

# Health check
GET /health
```

## 🚀 Deployment

### Prerequisites
- Google Cloud Project: `bni-prod-dma-bnimove-ai`
- Service Account: `document-processing-sa@bni-prod-dma-bnimove-ai.iam.gserviceaccount.com`
- Container Registry access
- Text analysis model endpoint: `https://nexus-bnimove-369455734154.asia-southeast2.run.app`

### Auto Deployment
Push to `main` branch triggers automatic deployment via Cloud Build:

```bash
# Setup GitHub trigger
gcloud builds triggers create github \
  --repo-name=your-api-repo-name \
  --repo-owner=your-github-username \
  --branch-pattern="^main$" \
  --build-config=cloudbuild.yaml
```

### Manual Deployment
```bash
# Build and deploy
gcloud run services replace api_service.yaml --region=asia-southeast1
```

## ⚙️ Configuration

### Environment Variables
- `GOOGLE_CLOUD_PROJECT`: bni-prod-dma-bnimove-ai
- `TEXT_MODEL_BASE_URL`: https://nexus-bnimove-369455734154.asia-southeast2.run.app
- `TEXT_MODEL_API_KEY`: sk-c2ebcb8d36aa4361a28560915d8ab6f2
- `GCS_BUCKET_NAME`: sbp-wrapper-bucket
- `PUBSUB_TOPIC`: document-processing-request
- `FIRESTORE_DATABASE`: document-processing-firestore

### Scaling
- **Min Instances**: 0
- **Max Instances**: 10
- **CPU**: 1 vCPU
- **Memory**: 2 GiB
- **Timeout**: 300 seconds

## 🔒 Security

- API key authentication
- Input sanitization and validation
- Rate limiting (1000 requests/hour)
- Audit logging for sensitive operations
- HTTPS only communication

## 📊 Monitoring

- Health check endpoint: `/health`
- Metrics collection via `text_analysis_metrics.py`
- Request/response logging
- Performance monitoring

## 🏃‍♂️ Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export GOOGLE_CLOUD_PROJECT=bni-prod-dma-bnimove-ai
export TEXT_MODEL_BASE_URL=https://nexus-bnimove-369455734154.asia-southeast2.run.app

# Run locally
python -m uvicorn app:app --host 0.0.0.0 --port 8080
```

## 📄 License

Internal BNI project - All rights reserved.