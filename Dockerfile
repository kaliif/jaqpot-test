FROM python:3.11.5-slim-bullseye as builder
# FROM euclia/jaqpotpy-inference:1.1.0
# FROM pytorch/pytorch:latest as builder


ENV PYTHONUNBUFFERED=1
ENV HOME=/code


# RUN apt-get -y update &&\
#   apt-get -y install procps &&\
#   apt-get clean


COPY requirements.txt /tmp/
RUN pip install --upgrade pip
# RUN pip install -r /tmp/requirements.txt
RUN pip wheel --no-cache-dir --wheel-dir /code/wheels -r /tmp/requirements.txt

# wrapt needs an upgrade for dm_job_utilities to work, but dm_job_utilities demands older version
# forcing upgrade here and seems to work
# RUN pip install -U wrapt


FROM python:3.11.5-slim-bullseye
# FROM pytorch/pytorch:latest

ENV PYTHONUNBUFFERED=1
ENV HOME=/code

RUN apt-get -y update &&\
  apt-get -y install procps &&\
  apt-get clean

COPY --from=builder /code/wheels /wheels
COPY --from=builder /tmp/requirements.txt /tmp/
RUN pip install --upgrade pip
RUN pip install --no-cache /wheels/*
RUN pip install -U wrapt

WORKDIR ${HOME}
COPY src/ ./

# can't copy to data, why?
# RUN mkdir /data/models/
# COPY models/ /data/models/

RUN mkdir ./models
COPY models/ ./models/
