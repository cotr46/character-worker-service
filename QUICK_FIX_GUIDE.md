# 🚀 Quick Fix Guide - 2 Minutes to Fix

## 🎯 **The ONE Critical Change:**

**File:** `worker_service/text_model_client.py`
**Line:** ~69 (around line 69)

**Change this:**
```python
self.chat_endpoint = f"{self.base_url}/api/chat/completions"
```

**To this:**
```python
self.chat_endpoint = f"{self.base_url}/chat/completions"
```

## 📋 **Steps:**

1. **Open your GitHub repository:** `character-worker-service`
2. **Navigate to:** `worker_service/text_model_client.py`
3. **Find line ~69** (search for `chat_endpoint`)
4. **Remove `/api`** from the endpoint
5. **Commit with message:** "Fix: Remove duplicate /api in endpoint"
6. **Push to main branch**
7. **Wait 3-5 minutes** for automated deployment
8. **Test PEP analysis** - should work!

## ✅ **That's it!**

Environment variables are already set correctly. This one line change will fix the "Model unavailable" error.

## 🧪 **Test Command:**
```bash
curl -X POST https://text-doc-api-service-369455734154.asia-southeast2.run.app/api/analyze-text/pep-analysis \
  -H 'Content-Type: application/json' \
  -d '{"name": "Test User", "entity_type": "person"}'
```