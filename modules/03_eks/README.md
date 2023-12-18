- 金額
  - クラスター
    - 0.1USD/1h
    - 24*31*0.1*14.29(Yen)=1063Yen/月
  - 他EC2,EBS,Outpostsキャパシティ等


```bash
aws eks --region us-east-1 update-kubeconfig --name eks-practice
kubectl config get-contexts
kubectl config get-contexts -o name | xargs -I {} kubectl config delete-context {} # all delete
kubectl get pods --all-namespaces
```

# kubernetes deploy
- kubectlを利用
- マニフェストファイル(yaml)にリソースを定義

```bash
kubectl apply -f sample-pod.yaml
kubecl delete -f sample-pod.yaml
```
