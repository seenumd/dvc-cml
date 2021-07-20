FROM ubuntu

FROM node:12

# INSTALL CORE DEPENDENCIES
RUN apt-get update \
 && apt-get install --no-install-recommends \
    build-essential \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/*
 
# INSTALL NODE, GIT
RUN apt-get update \
 && apt-get install --yes git nodejs sudo \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/*
 
# INSTALL CML
#RUN npm config set user 0 \npm install --global @dvcorg/cml
RUN npm install --global @dvcorg/cml

# INSTALL VEGA
RUN add-apt-repository universe --yes \
 && apt-get update \
 && apt-get install --yes \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    libfontconfig-dev \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* \
 && npm install --global canvas vega vega-cli vega-lite

FROM python:3.7

# INSTALL DVC
RUN python -m pip install pip --upgrade \
 && pip install dvc \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/*
 
# CONFIGURE RUNNER PATH
RUN mkdir /home/runner
WORKDIR /home/runner

COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# COMMAND
CMD ["dvc repro"]

ENV IN_DOCKER=1
#CMD ["cml-runner"]
CMD ["cml-runner --name myrunner --repo https://github.com/seenumd/dvc_cml --token=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 --labels cml  --idle-timeout 180"]

CMD ["dvc metrics show >> report.md"]
CMD ["cml-publish confusion_matrix.png --md >> report.md"]
CMD ["cml-send-comment report.md"]