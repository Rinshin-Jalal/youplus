#!/bin/bash

# Toggle between Preview-safe and Full modes for BigBruh app
# Run this script to enable/disable previews

INFO_PLIST="bigbruhh/Info.plist"

if grep -q "<!-- PREVIEW MODE -->" "$INFO_PLIST"; then
    echo "🔧 Switching to FULL MODE (with VoIP and background modes)..."
    sed -i '' 's/<!-- PREVIEW MODE -->//' "$INFO_PLIST"
    sed -i '' 's/<!--//' "$INFO_PLIST"
    sed -i '' 's/-->//' "$INFO_PLIST"
    echo "✅ FULL MODE enabled. VoIP and background modes active."
    echo "   You can now run on simulator/device."
    echo "   ⚠️  Previews will NOT work in this mode."
else
    echo "🔧 Switching to PREVIEW MODE (no VoIP, safe for previews)..."
    sed -i '' '/<key>UIBackgroundModes<\/key>/,/<\/array>/s/^/<!-- /' "$INFO_PLIST"
    sed -i '' '/<key>UIBackgroundModes<\/key>/,/<\/array>/s/$/ -->/' "$INFO_PLIST"
    sed -i '' 's/^<!-- <!-- /<!-- /' "$INFO_PLIST"
    sed -i '' 's/ --> -->/ -->/' "$INFO_PLIST"
    sed -i '' 's/^\([ \t]*\)<!-- /\1<!-- PREVIEW MODE -->\n\1<!-- /' "$INFO_PLIST"
    echo "✅ PREVIEW MODE enabled. VoIP and background modes disabled."
    echo "   Xcode Previews should now work!"
    echo "   ⚠️  Don't run on simulator/device in this mode."
fi

echo ""
echo "💡 Run this script again to toggle back."
