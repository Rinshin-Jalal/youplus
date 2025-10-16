#!/bin/bash

# 🧪 BigBruh Onboarding Test Script
# Tests the /onboarding/v3/complete endpoint with realistic data

# Configuration
BACKEND_URL="https://3d3fdceeb8e2.ngrok-free.app"
USER_ID="7e5a0541-8f03-453c-8527-1ad08c775180"
AUTH_TOKEN="eyJhbGciOiJIUzI1NiIsImtpZCI6IkpacFlrRzRDVDZpNldXNUciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL21waWNxbGxwcXR3ZmFmcXBwd2FsLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI3ZTVhMDU0MS04ZjAzLTQ1M2MtODUyNy0xYWQwOGM3NzUxODAiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzYwMDAwNDA1LCJpYXQiOjE3NTk5OTY4MDUsImVtYWlsIjoicmluc2hpbmphbGFsQGljbG91ZC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImFwcGxlIiwicHJvdmlkZXJzIjpbImFwcGxlIl19LCJ1c2VyX21ldGFkYXRhIjp7ImN1c3RvbV9jbGFpbXMiOnsiYXV0aF90aW1lIjoxNzU5OTk2ODAzfSwiZW1haWwiOiJyaW5zaGluamFsYWxAaWNsb3VkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJwcm92aWRlcl9pZCI6IjAwMTM3NC40YjA1OGYyYWVjN2Y0YTE1OTNlMzkzYjhmYjNlZWJiNi4wNzU4Iiwic3ViIjoiMDAxMzc0LjRiMDU4ZjJhZWM3ZjRhMTU5M2UzOTNiOGZiM2VlYmI2LjA3NTgifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJvYXV0aCIsInRpbWVzdGFtcCI6MTc1OTk5NjgwNX1dLCJzZXNzaW9uX2lkIjoiYTM4YWYzNGItOTZiNC00MmY5LWE3NzQtN2RlOWFlOWY3MWFkIiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.vjyz9gYOZg_MeA3tQYyCer5OlzFmuHSf6OOh1he3csg"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 BigBruh Onboarding Test${NC}"
echo -e "${BLUE}=========================${NC}"
echo "Backend: $BACKEND_URL"
echo "User ID: $USER_ID"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}📡 Test 1: Health Check${NC}"
curl -s "$BACKEND_URL/test" | jq '.' || echo "Health check failed"
echo ""

# Test 2: Onboarding Complete (Simplified)
echo -e "${YELLOW}📡 Test 2: Onboarding Complete (Simplified)${NC}"
curl -X POST "$BACKEND_URL/onboarding/v3/complete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{
    "state": {
      "currentStep": 45,
      "totalResponses": 5,
      "progressPercentage": 100,
      "isCompleted": true,
      "startedAt": "2025-01-09T07:50:00.000Z",
      "lastSavedAt": "2025-01-09T08:00:00.000Z",
      "completedAt": "2025-01-09T08:00:00.000Z",
      "userName": "RINSHIN",
      "callTime": "20:30",
      "userTimezone": "America/New_York",
      "responses": {
        "step_2": {
          "type": "voice",
          "value": "Stop the act. Stop the act. Say it louder.",
          "timestamp": "2025-01-09T07:53:29.000Z",
          "duration": 10
        },
        "step_3": {
          "type": "text",
          "value": "RINSHIN",
          "timestamp": "2025-01-09T07:53:36.000Z"
        },
        "step_5": {
          "type": "voice",
          "value": "Prove you are wrong. You are real.",
          "timestamp": "2025-01-09T07:53:50.000Z",
          "duration": 10
        },
        "step_6": {
          "type": "choice",
          "value": "Other people have it easier",
          "timestamp": "2025-01-09T07:53:55.000Z"
        },
        "step_37": {
          "type": "time_window_picker",
          "value": {
            "start": "20:30",
            "end": "21:00"
          },
          "timestamp": "2025-01-09T07:57:56.000Z"
        }
      }
    },
    "voipToken": null
  }' | jq '.' || echo "Onboarding complete failed"
echo ""

# Test 3: Identity Check
echo -e "${YELLOW}📡 Test 3: Identity Check${NC}"
curl -s "$BACKEND_URL/api/identity/$USER_ID" \
  -H "Authorization: Bearer $AUTH_TOKEN" | jq '.' || echo "Identity check failed"
echo ""

# Test 4: Extract Data (if identity failed)
echo -e "${YELLOW}📡 Test 4: Extract Data${NC}"
curl -X POST "$BACKEND_URL/onboarding/extract-data" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" | jq '.' || echo "Extract data failed"
echo ""

echo -e "${GREEN}✅ Tests completed!${NC}"
