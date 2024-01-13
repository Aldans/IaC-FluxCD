### Use local k8s KinD cluster with FluxCD

#### Pre-Required

Local KinD cluster

- install and configure docker
- install KinD

GitHub

- create token

Flux 

- install flux cli

#### Create IaC Terraform for new local k8s KinD cluster. 

1. Fork with all branchas TF modules for prepare infrastructure.

```
github.com/den-vasyliev/tf-kind-cluster
github.com/den-vasyliev/tf-fluxcd-flux-bootstrap
github.com/den-vasyliev/tf-github-repository
github.com/den-vasyliev/tf-hashicorp-tls-keys
```

2. Add this modules to main.tf file.

- For module kind cluster use branch `cert_auth`
- For module flux use branch `kind_auth`

3. Add varables.tf file and add needed variables.

```
- algorithm
- github_owner
- github_token
- repository_name
```
4. Create vars.tfvars file and fill sensitive data

```
- github_owner = "your github owner"
- github_token = "your github token"
```

5. Create infrastructure with terraform.

```sh
terraform init
terraform validate
terraform plan
terraform apply -var-file=vars.tfvars
```
After that if you did all right terraform will create and start your local KinD cluster also in your github repo will be create new repository with name act as you fill of variable `repository_name`

#### Check ns and flux controllers in KinD cluster

```sh
-> k get ns
NAME                 STATUS   AGE
default              Active   16m
flux-system          Active   15m
kube-node-lease      Active   16m
kube-public          Active   16m
kube-system          Active   16m
local-path-storage   Active   16m

-> k get po -n flux-system
NAME                                       READY   STATUS    RESTARTS   AGE
helm-controller-69dbf9f968-qsgq9           1/1     Running   0          16m
kustomize-controller-796b4fbf5d-jxqdx      1/1     Running   0          16m
notification-controller-78f97c759b-c8vpr   1/1     Running   0          16m
source-controller-7bc7c48d8d-c8kxk         1/1     Running   0          16m
```

#### CI/CD

The `dev-v7.3` branch has a CI pipeline for [kbot](github.com/aldans/kbot) repo defined in the ".github/workflows/cicd.yaml" file and is set up to automatically build, push to ghrc.io, and CD deploy using "Flux" to a k8s(local-kind, and optional to gcp) cluster after pushing a commit.

```sh
-> git clone https://github.com/aldans/flux-gitops.git
-> cd ../flux-gitops 
-> flux create source git kbot \
    --url=https://github.com/aldans/kbot \
    --branch=main \
    --namespace=demo \
    --export > clusters/demo/kbot-gr.yaml
-> flux create helmrelease kbot \
    --namespace=demo \
    --source=GitRepository/kbot \
    --chart="./helm" \
    --interval=1m \
    --export > clusters/demo/kbot-hr.yaml

-> git add .
-> git commit -m "add manifest"
-> git push

-> flux logs -f
2023-12-19T08:58:45.061Z info GitRepository/flux-system.flux-system - stored artifact for commit 'add manifest' 
2023-12-19T08:58:45.466Z info Kustomization/flux-system.flux-system - server-side apply for cluster definitions completed 
2023-12-19T08:58:45.559Z info Kustomization/flux-system.flux-system - server-side apply completed 
2023-12-19T08:58:45.596Z info Kustomization/flux-system.flux-system - Reconciliation finished in 498.659581ms, next run in 10m0s 
2023-12-19T08:59:46.501Z info GitRepository/flux-system.flux-system - garbage collected 1 artifacts 
```

**For local cluster need manualy add secrets telebot token and github token but before in cluster need delete empty secrets kbot and github and then add sencetive data and add this manifest to your cluster**

**EXAMPLES secrets:**

- github token

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-registry-secret
  namespace: demo
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: "" # your docker config json here in base64
```
- telebot token

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kbot
  namespace: demo
type: Opaque
data:
  key: "" # your tg token here in base64

```

Check pod kbot in demo ns:

```sh
-> k get po -n demo
NAME                              READY   STATUS    RESTARTS   AGE
kbot-helm-kbot-6fb7bffcb5-5655w   1/1     Running   0          2h
```


**Update tag for new version**

1. Run pull from remote repo.

2. Create local commit, add tag, push commit and push tag to remote repo.
   ```bash 
   git push origin dev-v7.3 && git push --tags origin dev-v7.3
     or
   git push origin dev-v7.3 --follow-tags 
   ```
   `--follow-tags` need config git `git config --global push.followTags true`
   
> If need change commit for current tag first delete tag on remote repo and del local tag than create local commit, add local tag,
  push commit and push tag to remote repo.

### Use FluxCD gitops on GKE cluster

#### Pre-Required

1. Acces for your GCP account.

2. Auth login from `gcloud` console.

```sh
gcloud auth login
```
3. Install FluxCD CLI

```sh
curl -s https://fluxcd.io/install.sh | sudo bash
```
4. Install infracost

```sh
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
```

5. Install Terraform if need.

**Create vars.tfvars file and fill sensitive data**

```
- GOOGLE_PROJECT = "your google project id"
- github_owner = "your github owner"
- github_token = "your github token"
```

**Create GKE cluster for that use terraform**

```sh
terraform init && \
terraform validate && \
terraform plan -var-file=vars.tfvars && \
infacost breakdown --path . && \
terraform apply -var-file=vars.tfvars
```
**After GKE cluster created check flux-system namespace in your cluster**

```sh
kubectl get ns
```

**Cloune your gitops repo and add your kbot repo then push updates**

Add folder `demo`, and files:

- ns.yaml
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo
```
- kbot-gh.yaml

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: kbot
  namespace: demo
spec:
  interval: 1m0s
  ref:
    branch: dev-v7.3
  url: https://github.com/Aldans/kbot
```

- kbot-hr.yaml

```yaml
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: kbot
  namespace: demo
spec:
  chart:
    spec:
      chart: ./helm
      reconcileStrategy: Revision
      sourceRef:
        kind: GitRepository
        name: kbot
  interval: 1m0s
```

Push this files to your gitops repo and check your cluster - pod will be created but have state error, for fix need recreate secrets 
manualy [kbot, github_token] with your github token and telebot token in cluster in namespace demo. Then delete pod and check pod with kbot can be created without errors.

