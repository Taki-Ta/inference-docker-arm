FROM continuumio/miniconda3:23.10.0-1

RUN apt-get update && apt-get install -y \
    libgomp1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/inference

COPY . .

ENV PIP_INDEX=https://pypi.org/simple

RUN python -m pip install --upgrade -i "$PIP_INDEX" pip

RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

RUN pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/xinference/deploy/docker/requirements_cpu-base.txt

RUN pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/xinference/deploy/docker/requirements_cpu-ml.txt

RUN pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/xinference/deploy/docker/requirements_cpu-models.txt

RUN cd /opt/inference && python setup.py build_web && git restore .

RUN pip install -i "$PIP_INDEX" --no-deps "."

RUN pip install -i "$PIP_INDEX" "xllamacpp>=0.1.18" || echo "xllamacpp installation failed, continuing without it"

RUN pip cache purge

CMD ["xinference"]
