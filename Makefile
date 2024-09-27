# 定义变量
HOSTNAME := $(shell hostname)
DOMAIN := $(HOSTNAME).nload.top
ETCD_CLUSTER := air=http://air.nload.top:2380,mini=http://mini.nload.top:2380,mba=http://mba.nload.top:2380

# 默认目标
all: down start-etcd

# 拉取etcd镜像
pull-image:
	@echo "拉取etcd镜像"
	@docker pull quay.io/coreos/etcd:v3.5.16

# 启动etcd
start-etcd: pull-image
	@echo "启动etcd服务"
	@docker run -d \
		--name etcd \
		--network host \
		-v /data/etcd:/etcd-data \
		quay.io/coreos/etcd:v3.5.16 \
		etcd \
		--name $(HOSTNAME) \
		--data-dir /etcd-data \
		--initial-advertise-peer-urls http://$(DOMAIN):2380 \
		--listen-peer-urls http://0.0.0.0:2380 \
		--listen-client-urls http://0.0.0.0:2379 \
		--advertise-client-urls http://$(DOMAIN):2379 \
		--initial-cluster $(ETCD_CLUSTER) \
		--initial-cluster-state new \
		--initial-cluster-token etcd-cluster-1 \
		--enable-v2=true

# 停止etcd服务
down:
	@echo "停止etcd服务"
	@docker rm -f etcd

# 显示配置信息
show:
	@echo "主机名: $(HOSTNAME)"
	@echo "域名: $(DOMAIN)"
	@echo "ETCD集群: $(ETCD_CLUSTER)"

.PHONY: all start-etcd down show pull-image
