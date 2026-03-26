FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    git \
    wget \
    libglib2.0-0 \
    libsm6 \
    ffmpeg \
    libgl1 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*


ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip
RUN pip install torch==2.9.0 torchvision==0.24.0 torchaudio==2.9.0 xformers==0.0.33.post1 --index-url https://download.pytorch.org/whl/cu128
RUN git clone https://github.com/zju3dv/InfiniDepth.git /app

WORKDIR /app

RUN pip install --no-cache-dir -r /app/requirements.txt
RUN pip install git+https://github.com/microsoft/MoGe.git
RUN pip install gsplat
RUN mkdir -p /app/checkpoints/depth /app/checkpoints/gs /app/checkpoints/moge-2-vitl-normal /app/checkpoints/sky
RUN wget https://huggingface.co/ritianyu/InfiniDepth/resolve/main/infinidepth.ckpt?download=true -O /app/checkpoints/depth/infinidepth.ckpt
RUN wget https://huggingface.co/ritianyu/InfiniDepth/resolve/main/infinidepth_depthsensor.ckpt?download=true -O /app/checkpoints/depth/infinidepth_depthsensor.ckpt
RUN wget https://huggingface.co/ritianyu/InfiniDepth/resolve/main/infinidepth_gs.ckpt?download=true -O /app/checkpoints/gs/infinidepth_gs.ckpt
RUN wget https://huggingface.co/ritianyu/InfiniDepth/resolve/main/infinidepth_depthsensor_gs.ckpt?download=true -O /app/checkpoints/gs/infinidepth_depthsensor_gs.ckpt
RUN wget https://huggingface.co/ritianyu/InfiniDepth/resolve/main/moge2.pt?download=true -O /app/checkpoints/moge-2-vitl-normal/moge2.pt
RUN wget https://huggingface.co/ritianyu/InfiniDepth/resolve/main/skyseg.onnx?download=true -O /app/checkpoints/sky/skyseg.onnx
RUN ln -s /app/checkpoints/moge-2-vitl-normal/moge2.pt /app/checkpoints/moge-2-vitl-normal/model.pt
EXPOSE 7860
ENV GRADIO_SERVER_NAME="0.0.0.0"
ENV GRADIO_SERVER_PORT="7860"
CMD ["python", "app.py"]

