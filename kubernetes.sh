#For Ubuntu 20.04

#Install general dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates \
  curl gnupg lsb-release


# Add docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor \
  -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add docker apt repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list

# Fetch the package lists from docker repository
sudo apt-get update

# Install docker and containerd
sudo apt-get install -y docker-ce docker-ce-cli containerd.io


# Configure docker to use overlay2 storage and systemd
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {"max-size": "100m"},
    "storage-driver": "overlay2"
}
EOF

# Restart docker to load new configuration
sudo systemctl restart docker

# Add docker to start up programs
sudo systemctl enable docker

# Allow current user access to docker command line
sudo usermod -aG docker $USER1

# Download cri-dockerd
curl -sSLo cri-dockerd_0.2.3.3-0.ubuntu-focal_amd64.deb \
  https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.3/cri-dockerd_0.2.3.3-0.ubuntu-focal_amd64.deb

# Install cri-dockerd for Kubernetes 1.24 support
sudo dpkg -i cri-dockerd_0.2.3.3-0.ubuntu-focal_amd64.deb

# Add Kubernetes GPG key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Fetch package list
sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

# Prevent them from being updated automatically
sudo apt-mark hold kubelet kubeadm kubectl

# See if swap is enabled
swapon --show

# Turn off swap
sudo swapoff -a

# Disable swap completely
sudo sed -i -e '/swap/d' /etc/fstab

#Create the cluster using kubeadm
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=/var/run/cri-dockerd.sock

#Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Untaint node
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

#Install a CNI plugin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#Install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

#Install a CSI driver
# Add openebs repo to helm
helm repo add openebs https://openebs.github.io/charts

#kubectl create namespace openebs

#helm --namespace=openebs install openebs openebs/openebs
sudo helm install -name openebs --namespace openebs openebs/openebs --create-namespace

#Install Wordpress
# Add bitnami repo to helm
helm repo add bitnami https://charts.bitnami.com/bitnami

#helm install wordpress bitnami/wordpress \
#  --set=global.storageClass=openebs-hostpath


helm install wordpress bitnami/wordpress \
  --set=service.type=NodePort  --set=global.storageClass=openebs-hostpath
