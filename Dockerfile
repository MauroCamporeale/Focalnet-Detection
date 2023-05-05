ARG PYTORCH="1.10.0"
ARG CUDA="11.3"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC
RUN apt-get update

RUN apt install unzip

RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install MMCV
RUN pip install mmcv-full==1.3.18 -f https://download.openmmlab.com/mmcv/dist/cu113/torch1.10.0/index.html
# Install MMDetection (with swin-transformer and focalnet)
RUN conda clean --all

RUN pip install timm

RUN git clone -b 22.03-t5-patch https://github.com/NVIDIA/apex /apex
WORKDIR /apex
RUN pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./

WORKDIR ../

RUN git clone -b focal-net --single-branch https://github.com/MauroCamporeale/Focalnet-Detection.git /focalnet
WORKDIR /focalnet
ENV FORCE_CUDA="1"
RUN pip install -r requirements/build.txt
RUN pip install --no-cache-dir -e .