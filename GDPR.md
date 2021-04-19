# To check if a given name/email exists in DevStats

- Go to `devstats-test` and/or `devstats-prod` node `ssh root@master`.
- Go to `cd cncf/devstats-helm; git pull`, run: `helm install devstats-test-reports ./devstats-helm --set skipSecrets=1,skipPVs=1,skipBackupsPV=1,skipVacuum=1,skipBackups=1,skipBootstrap=1,skipProvisions=1,skipCrons=1,skipAffiliations=1,skipGrafanas=1,skipServices=1,skipPostgres=1,skipIngress=1,skipStatic=1,skipAPI=1,skipNamespaces=1,reportsPod=1,projectsOverride='+cncf\,+opencontainers\,+istio\,+knative\,+zephyr\,+linux\,+rkt\,+sam\,+azf\,+riff\,+fn\,+openwhisk\,+openfaas\,+cii\,+prestodb\,+godotengine'`.
- Shell into the reporting pod: `../devstats-k8s-lf/util/pod_shell.sh devstats-reports`, run `./sh/gdpr 'Name Surname' 'email@domain.com' ...`.
- If any data matches, we need to anonymize in in `cncf/gitdm`: `./add_forbidden_data.rb 'data to be' removed 'email@domain.com'`.
- Search all `cncf/gitdm` files: `./handle_forbidden_data.sh`, remove occurences reported by this script. Commit changes.
- Finally delete the reporting pod: `helm delete devstats-test-reports`.
