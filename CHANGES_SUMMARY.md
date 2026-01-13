# Text Analysis Bug Fix - Changes Summary

## 🐛 **Bug Fixed:**
- **Issue**: Model 'politically-exposed-person-v2' is currently unavailable
- **Root Cause**: Double `/api` in endpoint URL
- **Solution**: Remove duplicate `/api` from text_model_client.py

## 📝 **Files Changed:**

### **CRITICAL FIX (MUST UPDATE):**
1. **`worker_service/text_model_client.py`** - Line ~69
   - **BEFORE**: `self.chat_endpoint = f"{self.base_url}/api/chat/completions"`
   - **AFTER**: `self.chat_endpoint = f"{self.base_url}/chat/completions"`

### **OPTIONAL (Already handled via Cloud Run Console):**
2. **`worker_service/worker_service.yaml`** - Environment variables
3. **`api_service/api_service.yaml`** - Environment variables

## 🚀 **Deployment Process:**

### **What's Already Done:**
✅ Environment variables set directly on Cloud Run services
✅ Services are running with correct configuration
✅ Health checks passing (all 5 models healthy)

### **What You Need to Do:**
1. **Update `worker_service/text_model_client.py`** in your GitHub repo
2. **Push to GitHub** - automated deployment will trigger
3. **Wait 3-5 minutes** for Cloud Build to complete
4. **Test PEP analysis** - should work without "Model unavailable" error

## 🧪 **Testing:**

After deployment, test with:
```bash
curl -X POST https://text-doc-api-service-369455734154.asia-southeast2.run.app/api/analyze-text/pep-analysis \
  -H 'Content-Type: application/json' \
  -d '{"name": "Juhana S.E.", "entity_type": "person", "additional_context": "Test analysis"}'
```

## 📋 **Environment Variables Set:**

All environment variables are already configured on both services:
- ✅ OPENWEBUI_BASE_URL=https://nexus-bnimove-369455734154.asia-southeast2.run.app
- ✅ OPENWEBUI_API_KEY=sk-c2ebcb8d36aa4361a28560915d8ab6f2
- ✅ TEXT_ANALYSIS_ENABLED=true
- ✅ All model configurations
- ✅ All worker configurations
- ✅ All monitoring configurations

## 🎯 **Expected Result:**

After updating the code and automated deployment:
- ✅ PEP analysis requests should complete successfully
- ✅ No more "Model unavailable" errors
- ✅ Text analysis working for all 5 model types

## 📞 **Support:**

If issues persist after deployment:
1. Check Cloud Build logs for deployment status
2. Check Cloud Run logs for runtime errors
3. Verify the code change was deployed by checking the image SHA