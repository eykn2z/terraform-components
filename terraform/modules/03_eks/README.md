- 金額
  - クラスター
    - 0.1USD/1h
    - 24*31*0.1*14.29(Yen)=1063Yen/月
  - 他EC2,EBS,Outpostsキャパシティ等


```bash
aws eks --region us-east-1 update-kubeconfig --name eks-practice --region us-east-1 --profile terrafo
rm # profileを合わせる
kubectl config view --minify # config確認
kubectl config get-contexts
kubectl config get-contexts -o name | xargs -I {} kubectl config delete-context {} # all delete
% kubectl get pods --all-namespaces
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          7s
```

# kubernetes deploy
- kubectlを利用
- マニフェストファイル(yaml)にリソースを定義

```bash
kubectl apply -f sample-pod.yaml
kubecl delete -f sample-pod.yaml
```

# SockShop
Weaveworks社公開demoアプリ
```
kubectl create namespace px-sock-shop
curl -O https://raw.githubusercontent.com/pixie-labs/pixie-demos/main/eks-workshop/complete-demo.yaml manifests/
kubectl apply -f ./manifests/complete-demo.yaml
```
- ALBのDNSにアクセス
- front-endが30001ポートでlisten(ターゲットグループがlistenし、80ポートに転送)
- アクセス出来ない時
  - ngがALBと疎通可能になっていないとhealthyにならない(sgのインバウンドのリソースがsg指定になっていて、ng,ALBのsgが一致していない等)


# ツール
- kustomize
- helm
- ArgoCD
- prometheus
