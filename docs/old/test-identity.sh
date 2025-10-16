#!/bin/bash

# 🧪 Identity Extraction Test Script
# Quick way to test the intelligent identity system without full onboarding

USER_ID="test-user-$(date +%s)"
BASE_URL="http://localhost:8787"

echo "🧪 Testing Intelligent Identity Extraction System"
echo "👤 Test User ID: $USER_ID"
echo ""

# Test with basic mock data
echo "📊 Testing with BASIC mock data..."
curl -X POST "$BASE_URL/debug/identity-test" \
  -H "Content-Type: application/json" \
  -d "{\"userId\":\"$USER_ID\",\"mockLevel\":\"basic\"}" | jq '.'

echo ""
echo "---"
echo ""

# Test with full mock data  
echo "📊 Testing with FULL mock data..."
curl -X POST "$BASE_URL/debug/identity-test" \
  -H "Content-Type: application/json" \
  -d "{\"userId\":\"$USER_ID\",\"mockLevel\":\"full\"}" | jq '.'

echo ""
echo "---"
echo ""

# Check the identity record
echo "👁️ Checking saved identity record..."
curl -X GET "$BASE_URL/api/identity/$USER_ID" | jq '.'

echo ""
echo "---"
echo ""

# Clean up test data
echo "🗑️ Cleaning up test data..."
curl -X DELETE "$BASE_URL/debug/identity-test/$USER_ID" | jq '.'

echo ""
echo "✅ Test completed!"