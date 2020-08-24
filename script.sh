ISTIO_EXTRACTED_AT="/mnt/storage/jpkroehling/Tools/istio/istio-1.7.0"
BASE_DIR="/home/jpkroehling/Documents/Work/Red Hat/Devoxx 2019"
CONTAINER_PREFIX="quay.io/jpkroehling/devoxx"

# setup
## provision a Kubernetes cluster with minikube
minikube start --vm-driver kvm2 --cpus 6 --memory 20480 --container-runtime=crio --addons=ingress

## install istio
istioctl install --set profile=demo
kubectl label namespace default istio-injection=enabled

## wait until all istio services are stable
watch -n 0.5 kubectl get pods -n istio-system

## add the jaeger-collector headless service, for gRPC load balancing
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: jaeger-collector-headless
  namespace: istio-system
  labels:
    app: jaeger
    jaeger-infra: collector-service
spec:
  ports:
  - name: jaeger-collector-grpc
    port: 14250
    targetPort: 14250
    protocol: TCP
  selector:
    app: jaeger
  clusterIP: None
EOF

# applications
for app in order account inventory
do
version=$(date +%F_%H%M%S --utc)
app_name="service-mesh-${app}"
image="${CONTAINER_PREFIX}-${app}:${version}"

cd "${BASE_DIR}/${app_name}/"
./mvnw clean package -DskipTests
docker build -f src/main/docker/Dockerfile.jvm -t "${image}" .
docker push "${image}"
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${app_name}
  annotations:
    sidecar.jaegertracing.io/inject: jaeger
  labels:
    app: ${app_name}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${app_name}
  template:
    metadata:
      labels:
        app: ${app_name}
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - name: ${app_name}
        image: ${image}
        env:
        - name: JAEGER_SERVICE_NAME
          value: ${app_name}.default
        ports:
        - containerPort: 8080
          name: http
      - name: jaeger-agent
        image: jaegertracing/jaeger-agent:1.14
        args:
        - --reporter.grpc.host-port=dns:///jaeger-collector-headless.istio-system.svc.cluster.local:14250
        - --jaeger.tags=${app_name}.version=${version},pod=\${POD_NAME:unknown},namespace=\${POD_NAMESPACE:unknown}
        ports:
        - containerPort: 5778
          name: config-rest
        - containerPort: 6831
          name: jg-compact-trft
          protocol: UDP
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app: ${app_name}
  name: ${app_name}
spec:
  ports:
  - name: http
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: ${app_name}
  type: ClusterIP
EOF
done

### gateway ###
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: order-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: order
spec:
  hosts:
  - "*"
  gateways:
  - order-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: service-mesh-order
        port:
          number: 8080
EOF

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export INGRESS_HOST=$(minikube ip)
echo "Orders is at: ${INGRESS_HOST}:${INGRESS_PORT}/"
