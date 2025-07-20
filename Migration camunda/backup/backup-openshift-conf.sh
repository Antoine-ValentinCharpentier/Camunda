#!/bin/bash

# --- 0. Paramètres ---

NAMESPACE=camunda

DEPLOY_DIR="$BACKUP_DIR/deployments"
VALUES_FILE="$BACKUP_DIR/values.yaml"
CHART_INFO_FILE="$BACKUP_DIR/chart-version.txt"

mkdir -p "$DEPLOY_DIR"

# --- 1. Récupération de la version de la chart Helm ---

echo ">>> Récupération de la version de la chart Helm..."
CHART_VERSION=$(helm list -n "$NAMESPACE" | grep "$RELEASE_NAME" | awk '{print $9}')
if [ -z "$CHART_VERSION" ]; then
  echo "-> Impossible de trouver la version de la chart pour le release '$RELEASE_NAME'."
  exit 1
fi
echo "-> Version de la chart : $CHART_VERSION"
echo "$CHART_VERSION" > "$CHART_INFO_FILE"

# --- 2. Récupération des valeurs Helm ---

echo ">>> Sauvegarde des valeurs Helm..."
helm get values "$RELEASE_NAME" -n "$NAMESPACE" -o yaml > "$VALUES_FILE"
echo "-> Fichier des valeurs enregistré : $VALUES_FILE"

# --- 3. Export brut de chaque Deployment ---

echo ">>> Export des Deployments..."
for DEPLOY in $(oc get deploy -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}'); do
  echo "-  Exporting $DEPLOY..."
  oc get deploy "$DEPLOY" -n "$NAMESPACE" -o yaml > "$DEPLOY_DIR/$DEPLOY.yaml"
done

echo "-> Tous les déploiements ont été exportés dans : $DEPLOY_DIR"

echo ">>> Dossier complet de sauvegarde : $BACKUP_DIR"