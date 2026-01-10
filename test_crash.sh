#!/bin/bash

# Script de test pour reproduire le crash "Lost connection to device"
# Usage: ./test_crash.sh

echo "=========================================="
echo "Test de Reproduction du Crash Audio"
echo "=========================================="
echo ""

# Clean build
echo "1. Cleaning build artifacts..."
flutter clean
echo "✅ Clean done"
echo ""

# Get dependencies
echo "2. Getting dependencies..."
flutter pub get
echo "✅ Dependencies downloaded"
echo ""

# Create logs directory
mkdir -p logs
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="logs/app_log_${TIMESTAMP}.txt"

echo "3. Starting app with verbose logging..."
echo "   Logs will be saved to: $LOG_FILE"
echo ""
echo "=========================================="
echo "Instructions de Test:"
echo "=========================================="
echo "1. Attendez que l'app démarre"
echo "2. Naviguez vers 'Videos'"
echo "3. Lisez une vidéo YouTube"
echo "4. Revenez à l'écran principal"
echo "5. Allez vers 'Radio'"
echo "6. Démarrez la lecture audio"
echo "7. Attendez 5-10 secondes"
echo "8. Mettez en PAUSE"
echo "9. Observez si 'Lost connection to device' apparaît"
echo ""
echo "Appuyez sur Entrée pour continuer..."
read

# Run with verbose logging
flutter run --verbose 2>&1 | tee "$LOG_FILE"

echo ""
echo "=========================================="
echo "Test terminé"
echo "=========================================="
echo "Logs sauvegardés dans: $LOG_FILE"
echo ""
echo "Pour analyser les logs:"
echo "  grep -i 'error\|exception\|lost\|crash' $LOG_FILE"
echo ""
echo "Pour voir les logs AudioPlayerService:"
echo "  grep 'AudioPlayerService' $LOG_FILE"
echo ""
