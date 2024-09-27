# 高可用 PostgreSQL 集群

本项目用于搭建基于 etcd、Patroni 和 HAProxy 实现的高可用 PostgreSQL 集群。

## 目录

1. [前提条件](#前提条件)
2. [项目结构](#项目结构)
3. [使用步骤](#使用步骤)
4. [管理命令](#管理命令)
5. [注意事项](#注意事项)
6. [故障排除](#故障排除)
7. [可能存在的问题](#可能存在的问题)

## 版本信息

- PostgreSQL: 16.x
- Patroni: 3.x
- etcd: 3.5.x
- HAProxy: 2.x

## 前提条件

- 三台（至少一台，推荐单数）可以互相通信的 Linux 主机，推荐使用 Debian
- Docker
- Docker Compose
- Make

## 项目结构

- `Makefile`: 用于管理 etcd 服务
- `docker-compose.yml`: 定义 Patroni 和 HAProxy 服务
- `patroni.yml`: Patroni 配置文件
- `haproxy.cfg`: HAProxy 配置文件

## 使用步骤

1. 拷贝项目并配置环境变量

   将本项目拷贝到所有节点,然后复制 .env.example 文件为 .env 并根据实际情况修改其中的环境变量:

   ```
   cp .env.example .env
   ```

   编辑 .env 文件,设置适当的值。

2. 修改 Makefile

   根据您的环境修改以下变量:

   - `HOSTNAME`: 当前主机名
   - `DOMAIN`: 当前主机的域名
   - `ETCD_CLUSTER`: etcd 集群的配置

3. 修改 docker-compose.yml

   调整以下环境变量:

   - `PATRONI_NAME`: Patroni 节点名称
   - `PATRONI_ETCD_HOSTS`: etcd 集群地址
   - `PATRONI_RESTAPI_USERNAME`和`PATRONI_RESTAPI_PASSWORD`: REST API 的用户名和密码
   - `PATRONI_SUPERUSER_USERNAME`和`PATRONI_SUPERUSER_PASSWORD`: PostgreSQL 超级用户的用户名和密码
   - `PATRONI_REPLICATION_USERNAME`和`PATRONI_REPLICATION_PASSWORD`: 复制用户的用户名和密码
   - `PATRONI_POSTGRESQL_LISTEN`和`PATRONI_POSTGRESQL_CONNECT_ADDRESS`: PostgreSQL 监听地址

4. 自定义 Patroni 配置

   `patroni.yml`文件一般不需要修改，因为`docker-compose.yml`中配置的参数会覆盖默认的配置。
   如果需要修改，可以参考这里：https://patroni.readthedocs.io/en/latest/ENVIRONMENT.html

5. 自定义 HAProxy 配置

   编辑`haproxy.cfg`文件，修改`listen postgres`段落中的`server`配置，添加或修改后端 PostgreSQL 节点的地址。

6. 启动 etcd 集群

   在每个节点上运行:

   ```
   make all
   ```

7. 启动 Patroni 和 HAProxy

   运行:

   ```
   docker-compose up -d
   ```

## 管理命令

- 查看配置信息: `make show`
- 停止 etcd 服务: `make down`

## 注意事项

- 确保在启动 Patroni 之前,etcd 集群已经正常运行。
- 根据实际情况修改`docker-compose.yml`中的环境变量,特别是主机名和密码等敏感信息。
- 请妥善保管数据目录(`/data/pg16-ha/`)和配置文件。
- 在生产环境中,建议使用更安全的方式管理密码,如使用环境变量或密钥管理系统。
- 修改 Patroni 和 HAProxy 配置后,需要重启相应的服务以使更改生效。

## Dockerfile 说明

我们使用了一个自定义的基础镜像 `lerrybin/postgresql16-zhparser`，这个镜像包含了 PostgreSQL 16 和中文分词插件 zhparser。

Dockerfile 的主要步骤如下：

1. 更改 Debian 源为中国科技大学的镜像，以加快后续软件安装速度。

2. 安装 Python3 和 pip，为后续安装 Patroni 做准备。

3. 创建 Python 虚拟环境，并将其添加到 PATH 中。

4. 使用阿里云的 PyPI 镜像安装 Patroni 及其依赖。

5. 设置入口点为 Patroni，使用 `/etc/patroni.yml` 作为配置文件。

这个 Dockerfile 的主要目的是在包含 PostgreSQL 和中文分词插件的基础上，添加 Patroni 支持，并通过使用国内镜像源来优化构建过程，提高在中国网络环境下的构建速度。

## 故障排除

如果遇到问题,请检查:

1. etcd 集群是否正常运行
2. 网络连接是否正常
3. 配置文件是否正确
4. 各服务的日志输出

## 可能存在的问题

1. 如果 patroni 启动，提示 waiting for leader to bootstrap，参考 https://www.cnblogs.com/abclife/p/12348559.html
2. 如果遇到 postgres 权限问题，可能需要运行 `chown -R 999:999 /data/pg16-ha`

如需更多帮助,请查看项目文档或提交 issue。
