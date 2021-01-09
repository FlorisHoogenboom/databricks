# Databricks docker image

A simple Python & JVM enabled docker image that can be used to interact with Databricks.

Contains:
- Utilities to setup credentials from keyvault
- MLFlow
- Databricks-cli
- Databricks-Connect

## Motivation
This docker image can be used as part of a CI-pipline, for example to fetch a model from an MLFlow experiment in databricks and package it together with your inference job to be deployed.

### Example
One may have a `run-id` parameter stored in some YAML file in your repository that points to the MLFlow run that has the latest model you wish to deploy. When you for example want to package this model and serve it as an API you might do one of two things: (1) you fetch the model from MLFlow at runtime when the API container starts or (2) you package the model in the container when you build it. The former ofcourse provides you an extra run-time dependency and does not give you atomic deployments. It is the latter option where this container comes in useful: during your CI pipeline you can use this container to fetch a model from MLFlow and subsequently build and package it with your API container. This allows you to have full control over what is running in production via a single place: your git repository.

## Setting up the connection
To connect this docker image to databricks provide the `DATABRICKS_HOST` and `DATABRICKS_TOKEN` environment variables to the container.