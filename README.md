

# ![Apollo](img/ApolloLogo_100x36.png) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.268535.svg)](https://doi.org/10.5281/zenodo.268535) [![Docker Repository on Quay](https://quay.io/repository/gmod/docker-apollo/status "Docker Repository on Quay")](https://quay.io/repository/gmod/docker-apollo)

> Apollo is a browser-based tool for visualisation and editing of sequence
> annotations. It is designed for distributed community annotation efforts,
> where numerous people may be working on the same sequences in geographically
> different locations; real-time updating keeps all users in sync during the
> editing process.

## Quickstart

If you've never used docker before, first you will need to [install it](https://docs.docker.com/engine/installation/).

There are several flavours of Apollo images, based on your needs:

Image      | Contents                       | Comments
---------- | ------------------------------ | -------------
`:latest`  | Apollo + Chado + JBrowse Tools | This is the easiest image to get started with. Just run `docker run -it -p 8080:8080 quay.io/gmod/docker-apollo`
`:unified` | Apollo + Chado                 | Very similar to the `:latest` image, but does not include the JBrowse tools. Use this if you already have a JBrowse instance you wish to annotate
`:bare`    | Apollo                         | The most lightweight image, especially for admins and people wishing to deploy Apollo in production.

You can launch these images with `docker run` commands:

```console
$ docker run -it -p 8080:8080 quay.io/gmod/docker-apollo:latest
$ docker run -it -p 8080:8080 quay.io/gmod/docker-apollo:unified
```

If you need to load data, you can mount a volume into the docker container:

```console
$ docker run -it -v /jbrowse/dir/:/data -p 8080:8080 quay.io/gmod/docker-apollo
```

When you access this data within Apollo, you should refer to `/jbrowse/dir/my-organism` as `/data/my-organism`

### Logging In

The default credentials in this image are:

| Credentials |                    |
| ---         | ------------------ |
| Username    | `admin@local.host` |
| Password    | `password`         |


### Loading Data

Sample data is available within the container thanks to the JBrowse installation in this image. E.g.:

- `/JBrowse-1.12.3/sample_data/json/volvox`
- `/JBrowse-1.12.3/sample_data/json/yeast`
- `/JBrowse-1.12.3/sample_data/json/modencode`
