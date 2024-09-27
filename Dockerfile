FROM lerrybin/postgresql16-zhparser

RUN sed -Ei 's/(deb|security)\.debian\.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && \
    apt-get -y install python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip3 install --no-cache-dir patroni[psycopg2-binary,etcd3] -i https://mirrors.aliyun.com/pypi/simple/

ENTRYPOINT ["patroni", "/etc/patroni.yml"]