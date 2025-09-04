# puppet-uv

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with uv](#setup)
    * [What uv affects](#what-uv-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with uv](#beginning-with-uv)


## Description

puppet-uv installs [astral uv](https://docs.astral.sh/uv/), a fast Python package
manager written in Rust. It can also manage uv virtual environments.

## Setup

### Beginning with uv

To install `uv`:
```
include uv::install
```

To create a uv virtual environment:
``` 
uv::venv { 'venv1':

}
```
