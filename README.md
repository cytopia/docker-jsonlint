# Docker image for `jsonlint`

[![Build Status](https://travis-ci.com/cytopia/docker-jsonlint.svg?branch=master)](https://travis-ci.com/cytopia/docker-jsonlint)
[![Tag](https://img.shields.io/github/tag/cytopia/docker-jsonlint.svg)](https://github.com/cytopia/docker-jsonlint/releases)
[![](https://images.microbadger.com/badges/version/cytopia/jsonlint:latest.svg)](https://microbadger.com/images/cytopia/jsonlint:latest "jsonlint")
[![](https://images.microbadger.com/badges/image/cytopia/jsonlint:latest.svg)](https://microbadger.com/images/cytopia/jsonlint:latest "jsonlint")
[![](https://img.shields.io/badge/github-cytopia%2Fdocker--jsonlint-red.svg)](https://github.com/cytopia/docker-jsonlint "github.com/cytopia/docker-jsonlint")
[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

> #### All awesome CI images
>
> [ansible-lint](https://github.com/cytopia/docker-ansible-lint) |
> [awesome-ci](https://github.com/cytopia/awesome-ci) |
> [jsonlint](https://github.com/cytopia/docker-jsonlint) |
> [terraform-docs](https://github.com/cytopia/docker-terraform-docs) |
> [yamllint](https://github.com/cytopia/docker-yamllint)


[![Docker hub](http://dockeri.co/image/cytopia/jsonlint)](https://hub.docker.com/r/cytopia/jsonlint)


Dockerized version of [jsonlint](https://github.com/zaach/jsonlint)<sup>[1]</sup>, which adds
additional functionality such as **failure on wrong indentation**, lint **multiple files via wildcard**
search and being able to **ignore files** via wildcards.
The image is built nightly against the latest stable version of `jsonlint` and pushed to Dockerhub.

<sup>[1] Official project: https://github.com/zaach/jsonlint</sup>


## Available Docker image versions

| Docker tag | Build from |
|------------|------------|
| `latest`   | [Branch: master](https://github.com/zaach/jsonlint) |
| `1.6.0`    | [Tag: v1.6.0](https://github.com/zaach/jsonlint/tree/v1.6.0) |
<!--
| `1.5.0`    | [Tag: v1.5.0](https://github.com/zaach/jsonlint/tree/v1.5.0) |
| `1.4.1`    | [Tag: v1.4.1](https://github.com/zaach/jsonlint/tree/v1.4.1) |
| `1.4.0`    | [Tag: v1.4.0](https://github.com/zaach/jsonlint/tree/v1.4.0) |
| `1.3.2`    | [Tag: v1.3.2](https://github.com/zaach/jsonlint/tree/v1.3.2) |
| `1.2.0`    | [Tag: v1.2.0](https://github.com/zaach/jsonlint/tree/v1.2.0) |
| `1.1.1`    | [Tag: v1.1.1](https://github.com/zaach/jsonlint/tree/v1.1.1) |
| `1.1.0`    | [Tag: v1.1.0](https://github.com/zaach/jsonlint/tree/v1.1.0) |
| `1.0.1`    | [Tag: v1.0.1](https://github.com/zaach/jsonlint/tree/v1.0.1) |
-->


## Docker mounts

The working directory inside the Docker container is **`/data/`** and should be mounted locally to
where your JSON files are located.


## Usage

#### Display usage
```bash
$ docker run --rm cytopia/jsonlint --help

Usage: cytopia/jsonlint jsonlint [-sti] <PATH-TO-FILE>
       cytopia/jsonlint jsonlint [-sti] <GLOB-PATTERN>
       cytopia/jsonlint jsonlint --version
       cytopia/jsonlint jsonlint --help

 -s                 sort object keys
 -t CHAR            character(s) to use for indentation
 -i <GLOB-PATTERN>  Ignore glob pattern when using the GLOB-PATTERN for file search.
                    (e.g.: -i '\.terraform*.json')
 <PATH-TO-FILE>     Path to file to validate
 <GLOB-PATTERN>     Glob pattern for recursive scanning. (e.g.: *\.json)
                    Anything that "find . -name '<GLOB-PATTERN>'" will take is valid.
```

#### Check all JSON files and ignore `.terraform/` directories
```bash
$ docker run --rm cytopia/jsonlint -v $(pwd):/data -t '  ' -i '*.terraform/*' *.json
```

#### Check all JSON files for wrong indentation
This behaviour is achieved by saving the JSON with fixed indentation within the container in a
different location and then applying a diff against the original file.
```bash
$ docker run --rm cytopia/jsonlint -v $(pwd):/data -t '  ' *.json
```
```diff
jsonlint -c  -t '  ' ./envs/dev/iam-permission/dev-policy.json
jsonlint -c  -t '  ' ./envs/dev/iam-permission/ops-policy.json
--- ./envs/dev/iam-permission/ops-policy.json
+++ /tmp/ops-policy.json
@@ -154,7 +154,7 @@
       "Sid": "SageMakerFull",
       "Effect": "Allow",
       "Action": [
-         "sagemaker:*"
+        "sagemaker:*"
       ],
       "Resource": "*"
     },
```

## License

**[MIT License](LICENSE)**

Copyright (c) 2019 [cytopia](https://github.com/cytopia)
