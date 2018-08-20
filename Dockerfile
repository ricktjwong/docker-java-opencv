FROM ubuntu:16.04
LABEL maintainer "rickwtj@gmail.com"
VOLUME /mnt
# Install Docker
RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && apt-get install -y \
    mercurial xvfb locales sudo openssh-client parallel net-tools netcat bzip2 gnupg curl ssh ca-certificates zip
RUN set -ex \
  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*-ce\.tgz' | sort -r | head -n 1) \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
  && echo Docker URL: $DOCKER_URL \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && ls -lha /tmp/docker.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz \
  && which docker \
  && (docker version || true)
# docker compose
RUN COMPOSE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/docker-compose-latest" \
  && curl --silent --show-error --location --fail --retry 3 --output /usr/bin/docker-compose $COMPOSE_URL \
  && chmod +x /usr/bin/docker-compose \
  && docker-compose version
# install dockerize
RUN DOCKERIZE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/dockerize-latest.tar.gz" \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/dockerize-linux-amd64.tar.gz $DOCKERIZE_URL \
  && tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64.tar.gz \
  && rm -rf /tmp/dockerize-linux-amd64.tar.gz \
  && dockerize --version
RUN groupadd --gid 3434 circleci \
  && useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
  && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci
# Install all dependencies for OpenCV 3.4.2
RUN apt-get -y update && apt-get install -y build-essential cmake git \
    libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev \
    libtiff-dev libjasper-dev libdc1394-22-dev maven wget unzip \
    && apt-get install -y ant \
    && apt-get install -y openjdk-8-jdk \
    && apt-get install -y openjdk-8-jre \
    && wget https://github.com/opencv/opencv/archive/3.4.2.zip -O opencv-342.zip \
    && unzip -q opencv-342.zip && mv opencv-3.4.2 /opt && rm opencv-342.zip \
    && wget https://github.com/opencv/opencv_contrib/archive/3.4.2.zip -O opencv_contrib-342.zip \
    && unzip -q opencv_contrib-342.zip && mv opencv_contrib-3.4.2 /opt && rm opencv_contrib-342.zip \
    # chromedriver
    && wget https://chromedriver.storage.googleapis.com/2.40/chromedriver_linux64.zip -O chromedriver-240.zip \
    && unzip -q chromedriver-240.zip && mv chromedriver /opt && rm chromedriver-240.zip \
    # prepare build
    && mkdir /opt/opencv-3.4.2/build && mkdir /opt/opencv_files && cd /opt/opencv-3.4.2/build \
    && cmake -DOPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-3.4.2/modules /opt/opencv-3.4.2 \
      -DBUILD_opencv_java=ON \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF \
    # installation
    && make -j$(nproc) \
    && cp /opt/opencv-3.4.2/build/bin/opencv-342.jar /opt/opencv_files/ \
    && cp /opt/opencv-3.4.2/build/lib/libopencv_java342.so /opt/opencv_files/   
USER circleci