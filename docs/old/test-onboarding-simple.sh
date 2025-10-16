#!/bin/bash

# 🚀 Quick Onboarding Test - No jq required
BACKEND_URL="https://3d3fdceeb8e2.ngrok-free.app"
AUTH_TOKEN="eyJhbGciOiJIUzI1NiIsImtpZCI6IkpacFlrRzRDVDZpNldXNUciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL21waWNxbGxwcXR3ZmFmcXBwd2FsLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI3ZTVhMDU0MS04ZjAzLTQ1M2MtODUyNy0xYWQwOGM3NzUxODAiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzYwMDAwNDA1LCJpYXQiOjE3NTk5OTY4MDUsImVtYWlsIjoicmluc2hpbmphbGFsQGljbG91ZC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImFwcGxlIiwicHJvdmlkZXJzIjpbImFwcGxlIl19LCJ1c2VyX21ldGFkYXRhIjp7ImN1c3RvbV9jbGFpbXMiOnsiYXV0aF90aW1lIjoxNzU5OTk2ODAzfSwiZW1haWwiOiJyaW5zaGluamFsYWxAaWNsb3VkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJwcm92aWRlcl9pZCI6IjAwMTM3NC40YjA1OGYyYWVjN2Y0YTE1OTNlMzkzYjhmYjNlZWJiNi4wNzU4Iiwic3ViIjoiMDAxMzc0LjRiMDU4ZjJhZWM3ZjRhMTU5M2UzOTNiOGZiM2VlYmI2LjA3NTgifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJvYXV0aCIsInRpbWVzdGFtcCI6MTc1OTk5NjgwNX1dLCJzZXNzaW9uX2lkIjoiYTM4YWYzNGItOTZiNC00MmY5LWE3NzQtN2RlOWFlOWY3MWFkIiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.vjyz9gYOZg_MeA3tQYyCer5OlzFmuHSf6OOh1he3csg"

echo "🧪 Testing Onboarding Complete..."
echo "================================"

curl -X POST "$BACKEND_URL/onboarding/v3/complete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{
    "state": {
      "currentStep": 45,
      "totalResponses": 3,
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
  }'

echo ""
echo "✅ Test completed!"
