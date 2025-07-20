# Mode d’emploi – Réaliser une sauvegarde

Avant toute opération de mise à jour ou de migration, il est essentiel d’effectuer une sauvegarde de votre environnement Camunda. Cette sauvegarde vous permettra de restaurer les déploiements en cas de problème.

Le terme sauvegarde regroupe ici deux aspects essentiels :
- La sauvegarde du déploiement de Camunda
- La sauvegarde des instances des processus Camunda

Ce mode d’emploi détaille les étapes nécessaires pour réaliser ces deux types de sauvegarde.

## Sauvegarde des déploiements Camunda

Intéressons-nous dans un premier temps à la sauvegarde des déploiements Camunda.

Deux méthodes sont possibles :
- Utilisation du script automatisé
- Sauvegarde manuelle (pas à pas)

### Méthode 1 - Utilisation du script automatisé

Prérequis
- Avoir accès à un terminal
- oc (client OpenShift) installé
- helm installé
- Être connecté à OpenShift

Depuis votre terminal, placez-vous dans le répertoire où se trouve le script backup-openshift.sh

Lancez le, à l'aide de la commande suivante
```
./backup-openshift.sh
```

Vous obtiendrez un dossier structuré comme suit :
```
backup-XXX-YYY/
├── chart-version.txt
├── values.yaml
└── deployments/
    ├── camunda-zeebe.yaml
    ├── camunda-operate.yaml
    └── ...
```

### Méthode 2 - Sauvegarde manuelle (pas à pas)

// TODO : avec des screen venant d'openshift

## Sauvegarde des instances Camunda

Il faut ici créer une sauvegarde des données Elasticsearch utilisées par les applications web de Camunda (Operate, Optimize, etc.), ainsi que des données présentes dans la base de données RocketDB de Zeebe.

### Sauvegarde des données des applications web

```
export BACKUP_ID=$(date +%s)
export CAMUNDA_RELEASE_NAME="camunda"

export ELASTIC_SNAPSHOT_REPOSITORY="camunda" # the name of your snapshot repository
export ELASTIC_ENDPOINT="$CAMUNDA_RELEASE_NAME-elasticsearch:9200"

export OPERATE_MANAGEMENT_API="http://$CAMUNDA_RELEASE_NAME-operate:9600"
export OPTIMIZE_MANAGEMENT_API="http://$CAMUNDA_RELEASE_NAME-optimize:8092"
export TASKLIST_MANAGEMENT_API="http://$CAMUNDA_RELEASE_NAME-tasklist:9600"
export GATEWAY_MANAGEMENT_API="http://$CAMUNDA_RELEASE_NAME-zeebe-gateway:9600"
```


```
# Pour Optimize
curl -XPOST "$OPTIMIZE_MANAGEMENT_API/actuator/backups" \
   -H "Content-Type: application/json" \
   -d "{\"backupId\": $BACKUP_ID}"

# Pour Operate
curl -XPOST "$OPERATE_MANAGEMENT_API/actuator/backups" \
   -H "Content-Type: application/json" \
   -d "{\"backupId\": $BACKUP_ID}"

# Pour Tasklist
curl -XPOST "$TASKLIST_MANAGEMENT_API/actuator/backups" \
   -H "Content-Type: application/json" \
   -d "{\"backupId\": $BACKUP_ID}"
```

Veuillez attendre que la sauvegarde soit terminée à l'aide des commandes suivantes :

```
while [[ "$(curl -s "$OPERATE_MANAGEMENT_API/actuator/backups/$BACKUP_ID" | grep -oP '"state"\s*:\s*"\K[^"]+')" != "COMPLETED" ]]; do
  echo "Waiting..."
  sleep 5
done

while [[ "$(curl -s "$OPERATE_MANAGEMENT_API/actuator/backups/$BACKUP_ID" | grep -oP '"state"\s*:\s*"\K[^"]+')" != "COMPLETED" ]]; do
  echo "Waiting..."
  sleep 5
done

while [[ "$(curl -s "$OPERATE_MANAGEMENT_API/actuator/backups/$BACKUP_ID" | grep -oP '"state"\s*:\s*"\K[^"]+')" != "COMPLETED" ]]; do
  echo "Waiting..."
  sleep 5
done
echo "Finished backup with ID $BACKUP_ID"
```

### Sauvegarde des données de Zeebe

Pour Zeebe:
```
curl -XPOST "$GATEWAY_MANAGEMENT_API/actuator/exporting/pause?soft=true"
```

```
curl -XPUT "$ELASTIC_ENDPOINT/_snapshot/$ELASTIC_SNAPSHOT_REPOSITORY/camunda_zeebe_records_backup_$BACKUP_ID?wait_for_completion=true" \
-H 'Content-Type: application/json' \
-d '{
      "indices": "zeebe-record*",
      "feature_states": ["none"]
      }'

```
Attendre que le backup des indices de Zeebe soit terminé.
```
curl "$ELASTIC_ENDPOINT/_snapshot/$ELASTIC_SNAPSHOT_REPOSITORY/camunda_zeebe_records_backup_$BACKUP_ID/_status"
```

A tester (équivalent à la précédante requête, mais pas mentionné dans la doc) ->
```
while [[ "$(curl -s "$ELASTIC_ENDPOINT/_snapshot/$ELASTIC_SNAPSHOT_REPOSITORY/camunda_zeebe_records_backup_$BACKUP_ID/_status" | grep -oP '"state"\s*:\s*"\K[^"]+')" != "SUCCESS" ]]; do
  echo "Waiting..."
  sleep 5
done
echo "Finished backup with ID $BACKUP_ID"
```

Pour Zeebe-Gateway:
```
curl -XPOST "$GATEWAY_MANAGEMENT_API/actuator/backups" \
   -H "Content-Type: application/json" \
   -d "{\"backupId\": $BACKUP_ID}"
```

```
while [[ "$(curl -s "$GATEWAY_MANAGEMENT_API/actuator/backups/$BACKUP_ID" | grep -oP '"state"\s*:\s*"\K[^"]+')" != "COMPLETED" ]]; do
  echo "Waiting..."
  sleep 5
done
echo "Finished backup with ID $BACKUP_ID"
```