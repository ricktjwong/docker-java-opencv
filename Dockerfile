FROM ubuntu:16.04
LABEL maintainer "rickwtj@gmail.com"
# Install all dependencies for OpenCV 3.4.2
RUN apt-get -y update && apt-get -y install build-essential cmake git \
    libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev \
    libtiff-dev libjasper-dev libdc1394-22-dev wget unzip\
    && wget https://github.com/opencv/opencv/archive/3.4.2.zip -O opencv-342.zip \
    && unzip -q opencv-342.zip && mv opencv-3.4.2 /opt && rm opencv-342.zip \
    && wget https://github.com/opencv/opencv_contrib/archive/3.4.2.zip -O opencv_contrib-342.zip \
    && unzip -q opencv_contrib-342.zip && mv opencv_contrib-3.4.2 /opt && rm opencv_contrib-342.zip \
    # prepare build
    && mkdir /opt/opencv-3.4.2/build && cd /opt/opencv-3.4.2/build \
    && cmake -DOPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-3.4.2/modules /opt/opencv-3.4.2 \
      -DBUILD_opencv_java=ON \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF \
    # installation
    && make -j$(nproc) \
    # chromedriver \
    wget https://chromedriver.storage.googleapis.com/2.40/chromedriver_linux64.zip -O chromedriver-240.zip \
    && unzip -q chromedriver-240.zip && mv chromedriver /opt && rm chromedriver-240.zip