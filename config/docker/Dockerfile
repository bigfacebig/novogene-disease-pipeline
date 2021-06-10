FROM centos:latest

MAINTAINER suqingdong <suqingdong@novogene.com>

# ENV SOURCE_URL=https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
ENV SOURCE_URL=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh

RUN yum -y update \
    && yum -y install curl bzip2 \
    && curl -sSL $SOURCE_URL -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local/ \
    && rm -rf /tmp/miniconda.sh \
    && conda install -y python=3 \
    && conda update conda \
    && conda clean --all --yes \
    && rpm -e --nodeps curl bzip2 \
    && yum clean all
