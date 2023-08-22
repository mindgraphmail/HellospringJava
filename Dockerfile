#stage 1
FROM eclipse-temurin:8-jre-alpine as build
WORKDIR /application
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

#stage 2
FROM eclipse-temurin:8-jre-alpine

ARG USERNAME=nonroot
ARG GROUPNAME=${USERNAME}
ARG USER_UID=8877
ARG USER_GID=${USER_UID}

RUN addgroup -S -g ${USER_GID} ${GROUPNAME} \
&& adduser -S -u ${USER_UID} ${USERNAME} -G ${GROUPNAME}

WORKDIR /application
RUN chown ${USER_UID}:${USER_GID} /application
COPY --from=build --chown=${USER_UID}:${USER_GID} /application/dependencies/ ./
COPY --from=build --chown=${USER_UID}:${USER_GID} /application/spring-boot-loader/ ./
COPY --from=build --chown=${USER_UID}:${USER_GID} /application/snapshot-dependencies/ ./
COPY --from=build --chown=${USER_UID}:${USER_GID} /application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]

EXPOSE 8080
USER ${USERNAME}
