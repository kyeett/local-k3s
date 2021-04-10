

### Setup VMs
Launch three nodes
```
multipass launch -n n1
multipass launch -n n2
multipass launch -n n3
```

### Setup K3S
Initiate K3S control node (takes < 20s on my machine)
```
multipass exec n1 -- bash -c "curl -sfL https://get.k3s.io | sh -"
```

Get access token for joining, store IP
```shell
TOKEN=$(multipass exec n1 sudo cat /var/lib/rancher/k3s/server/node-token)
IP=$(multipass info n1 | grep IPv4 | awk '{print $2}')
```

Store k3s configuration to `host`
```shell
multipass exec n1 sudo cat /etc/rancher/k3s/k3s.yaml > k3s.yaml
```

In order to access the `host`, we need to change the IP from `127.0.0.1` to the IP of the VM (`n1`)
```shell
sed -i '' "s/127.0.0.1/$IP/" k3s.yaml
```

Finally, tell `kubectl` to use the k3s configuration file to talk to the configuration cluster
```shell
export KUBECONFIG=$PWD/k3s.yaml
```

```
multipass exec n2 -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
multipass exec n3 -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
```





## Other

```bash
sudo kubectl patch serviceaccount default \
               -p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'
```

Verify that secret has been added
```bash
sudo kubectl get serviceaccount default -o yaml
```


### Resources

* [Using Google Container Registry with Kubernetes](https://blog.container-solutions.com/using-google-container-registry-with-kubernetes) - Li Lian
