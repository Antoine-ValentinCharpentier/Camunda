#!/bin/bash

# --- 0. Paramètres ---

ELASTIC_SNAPSHOT_REPOSITORY="camunda" # the name of your snapshot repository
ELASTIC_ENDPOINT="$RELEASE_NAME-elasticsearch:9200"

OPERATE_MANAGEMENT_API="http://$RELEASE_NAME-operate:9600"
OPTIMIZE_MANAGEMENT_API="http://$RELEASE_NAME-optimize:8092"
TASKLIST_MANAGEMENT_API="http://$RELEASE_NAME-tasklist:9600"
GATEWAY_MANAGEMENT_API="http://$RELEASE_NAME-zeebe-gateway:9600"

# --- 2. Sauvegarde des instances Camunda (Optimize, Operate, Tasklist) ---

echo "Déclenchement des backups des applications web..."

for api_url in "$OPTIMIZE_MANAGEMENT_API" "$OPERATE_MANAGEMENT_API" "$TASKLIST_MANAGEMENT_API"; do
  echo "Demande de backup à $api_url..."
  curl -s -XPOST "$api_url/actuator/backups" \
    -H "Content-Type: application/json" \
    -d "{\"backupId\": $BACKUP_ID}" || echo "Erreur lors du backup sur $api_url"
done

echo "Attente de la fin des backups des applications web..."

for api_url in "$OPTIMIZE_MANAGEMENT_API" "$OPERATE_MANAGEMENT_API" "$TASKLIST_MANAGEMENT_API"; do
  echo "Vérification état backup sur $api_url ..."
  while [[ "$(curl -s "$api_url/actuator/backups/$BACKUP_ID" | grep -oP '"state"\s*:\s*"\K[^"]+')" != "COMPLETED" ]]; do
    echo "En attente... ($api_url)"
    sleep 5
  done
done

echo "Backups des applications web terminés."

# --- 3. Sauvegarde des données Zeebe ---

echo "Pause de l'export Zeebe..."
curl -s -XPOST "$GATEWAY_MANAGEMENT_API/actuator/exporting/pause?soft=true"

echo "Déclenchement du snapshot Elasticsearch pour les données Zeebe..."
curl -s -XPUT "$ELASTIC_ENDPOINT/_snapshot/$ELASTIC_SNAPSHOT_REPOSITORY/camunda_zeebe_records_backup_$BACKUP_ID?wait_for_completion=true" \
  -H 'Content-Type: application/json' \
  -d '{
        "indices": "zeebe-record*",
        "feature_states": ["none"]
      }'

echo "Attente de la complétion du snapshot Elasticsearch..."

while [[ "$(curl -s "$ELASTIC_ENDPOINT/_snapshot/$ELASTIC_SNAPSHOT_REPOSITORY/camunda_zeebe_records_backup_$BACKUP_ID/_status" | grep -oP '"state"\s*:\s*"\K[^"]+')" != "SUCCESS" ]]; do
  echo "En attente du snapshot Elasticsearch..."
  sleep 5
done

echo "Snapshot Elasticsearch terminé."

echo "Déclenchement du backup Zeebe-Gateway..."
curl -s -XPOST "$GATEWAY_MANAGEMENT_API/actuator/backups" \
   -H "Content-Type: application/json" \
   -d "{\"backupId\": $BACKUP_ID}"

echo "Attente de la fin du backup Zeebe-Gateway..."

while [[ "$(curl -s "$GATEWAY_MANAGEMENT_API/actuator/backups/$BACKUP_ID" | grep -oP '"state"\s*:\s*"\K[^"]+')" != "COMPLETED" ]]; do
  echo "En attente du backup Zeebe-Gateway..."
  sleep 5
done

echo "Backup Zeebe-Gateway terminé."

echo "=== Sauvegarde complète terminée ==="
echo "Les fichiers de déploiement sont disponibles dans : $BACKUP_DIR