#!/usr/bin/env bash
set -euo pipefail

# Usage: ./check-secret.sh <namespace> <secret-name> "key1 key2 ..."

if [ $# -ne 3 ]; then
  echo "Usage: $0 <namespace> <secret-name> \"key1 key2 ...\""
  exit 1
fi

NAMESPACE="$1"
SECRET_NAME="$2"
EXPECTED_KEYS="$3"

# Vérifie si le secret existe
if ! kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "❌ Secret '$SECRET_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Récupère les clés du secret (jsonpath donne une liste séparée par espaces)
ACTUAL_KEYS=$(kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.data}' | sed 's/map\[//;s/\]//g' | tr ' ' '\n')

MISSING=()
for key in $EXPECTED_KEYS; do
  if ! echo "$ACTUAL_KEYS" | grep -qx "$key"; then
    MISSING+=("$key")
  fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "✅ Secret '$SECRET_NAME' in namespace '$NAMESPACE' contains all required keys"
else
  echo "⚠️ Secret '$SECRET_NAME' in namespace '$NAMESPACE' is missing keys:"
  for k in "${MISSING[@]}"; do
    echo "  - $k"
  done
  exit 1
fi


≠=============
if ! kubectl get secret postgres-secret >/dev/null 2>&1; then
  kubectl create secret generic postgres-secret \
    --from-literal=username=myuser \
    --from-literal=password=mypassword
fi

kubectl apply -f postgres.yaml


========
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-initdb
data:
  init.sql: |
    CREATE DATABASE dbcambf;
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'myuser') THEN
        CREATE ROLE myuser LOGIN PASSWORD 'mypassword';
      END IF;
    END
    $$;
    GRANT ALL PRIVILEGES ON DATABASE dbcambf TO myuser;
    DROP ROLE IF EXISTS postgres;
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-initdb
data:
  init.sql: |
    -- On s'assure que l'utilisateur défini par POSTGRES_USER est bien superadmin
    ALTER ROLE "${POSTGRES_USER}" WITH SUPERUSER;
    -- On supprime l'utilisateur postgres par défaut
    DROP ROLE IF EXISTS postgres;
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  type: ClusterIP
  ports:
    - port: 5432
      name: postgres
  selector:
    app: postgres
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1   # un seul Pod PostgreSQL
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: username
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            - name: POSTGRES_DB
              value: dbcambf
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
            - name: initdb
              mountPath: /docker-entrypoint-initdb.d/
      volumes:
        - name: initdb
          configMap:
            name: postgres-initdb
            items:
              - key: init.sql
                path: init.sql
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        storageClassName: ceph-block   # ton StorageClass Ceph
        resources:
          requests:
            storage: 10Gi
