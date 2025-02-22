kubectl get secrets -n prgs
echo "-------"
echo "Username: $(kubectl get secret prgs-k8s-superuser -n prgs -oyaml -o=jsonpath={.data.username} | base64 -d | xargs)"
echo "-------"
echo "Password: $(kubectl get secret prgs-k8s-superuser -n prgs -oyaml -o=jsonpath={.data.password} | base64 -d | xargs)"
echo "-------"