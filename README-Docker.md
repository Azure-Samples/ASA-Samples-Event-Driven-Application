## Build the image

Starting with Spring Boot 2.3.0, a JAR file built with the Spring Boot Maven or Gradle plugin includes layer information in the JAR file. This layer information separates parts of the application based on how likely they are to change between application builds. This can be used to make Docker image layers even more efficient.

```bash
./mvnw clean package -DskipTests
java -Djarmode=layertools -jar target/*.jar extract --destination target/extracted
docker build -t xiadaacr.azurecr.io/asa-samples/event-driven .
```

### Push to acr

1. Enable anonymous pull

    ```bash
    az acr update --name xiadaacr  --anonymous-pull-enabled
    ```

2. Push image to acr

    ```bash
    az login
    az acr login --name xiadaacr
    docker push xiadaacr.azurecr.io/asa-samples/event-driven
    ```


## Run locally

1. Pull the image

    ```bash
    docker pull xiadaacr.azurecr.io/asa-samples/event-driven
    ```

2. Run it

    ```bash
    docker run -it -e SPRING_CLOUD_AZURE_SERVICEBUS_CONNECTIONSTRING="xxx" -p 8080:8080 xiadaacr.azurecr.io/asa-samples/event-driven
    ```

### Chech the env is set via actuator

Visit http://localhost:8080/actuator/env, and you will see something like:

![Envs in actuator endpoint](assets/actuator-env.png)

## References:
- [Spring Boot Docker](https://spring.io/guides/topicals/spring-boot-docker/)
- [Make your container registry content publicly available](https://learn.microsoft.com/en-us/azure/container-registry/anonymous-pull-access)
- [Push and pull an image](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?tabs=azure-cli)
- [Quickstart: Deploy an event-driven application to Azure Spring Apps
](https://learn.microsoft.com/en-us/azure/spring-apps/quickstart-deploy-event-driven-app-standard-consumption?pivots=sc-consumption-plan)