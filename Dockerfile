FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV TZ Asia/Seoul
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install \
    python3 python3-pip python3-dev \
    libgl1 unzip wget git ssh vim locales && \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    echo "root:root" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes #prohibit-password/' /etc/ssh/sshd_config

RUN locale-gen ko_KR.UTF-8
ENV LC_ALL ko_KR.UTF-8

WORKDIR /workspace

COPY requirements_min.txt .
RUN pip install --upgrade pip setuptools
RUN pip install torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu118
RUN pip install --no-cache-dir -r requirements_min.txt
RUN pip install "notebook<7.0.0" jupyterlab
RUN mkdir -p /root/.jupyter
RUN python3 -c "from notebook.auth import passwd; print(f\"c.NotebookApp.password = '{passwd('password')}'\")" > /root/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

WORKDIR /workspace
COPY . .

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

