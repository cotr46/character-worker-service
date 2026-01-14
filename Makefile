.PHONY: help deploy deploy-api deploy-worker health test clean

help:
	@echo "Available commands:"
	@echo "  make deploy         - Deploy both services"
	@echo "  make deploy-api     - Deploy API service"
	@echo "  make deploy-worker  - Deploy Worker service"
	@echo "  make health         - Check service health"
	@echo "  make test           - Run tests"
	@echo "  make clean          - Clean temporary files"

deploy:
	@echo "Deploying both services..."
	@bash scripts/deploy.sh

deploy-api:
	@echo "Deploying API service..."
	gcloud run services replace api_service/api_service.yaml --region=asia-southeast2

deploy-worker:
	@echo "Deploying Worker service..."
	gcloud run services replace worker_service/worker_service.yaml --region=asia-southeast2

health:
	@echo "Checking service health..."
	@bash scripts/health-check.sh

test:
	@echo "Running tests..."
	@bash tests/test-pep-analysis.sh

clean:
	@echo "Cleaning up..."
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.log" -delete 2>/dev/null || true
	@echo "Cleanup complete"
