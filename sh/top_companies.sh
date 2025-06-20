#!/bin/bash
kubectl exec -in devstats-prod devstats-postgres-1 -- psql allprj < sql/top_companies_by_contributions.sql
kubectl exec -in devstats-prod devstats-postgres-1 -- psql allprj < sql/top_companies_by_contributors.sql
