
# Builder
#
# The petclinic jar will be built in AzDO prior. Ideally, I'll also separate the build pipeline from the release pipeline. We'll see.
# But the goal here is only to bring in the Contrast agent at this time.

FROM ubuntu:latest as builder

ARG CONTRAST__DOWNLOAD__SERVER
ARG CONTRAST__DOWNLOAD__ORG_ID
ARG CONTRAST__DOWNLOAD__AUTH
ARG CONTRAST__DOWNLOAD__API_KEY

#CONTRAST SETUP

WORKDIR /contrast



RUN apt-get update && apt-get -y upgrade && apt-get -y install curl

RUN curl -X GET      $CONTRAST__DOWNLOAD__SERVER/Contrast/api/ng/$CONTRAST__DOWNLOAD__ORG_ID/agents/default/JAVA      -H "Authorization: $CONTRAST__DOWNLOAD__AUTH"   -H "API-Key: $CONTRAST__DOWNLOAD__API_KEY"      -H "Accept: application/json" > contrast.jar


RUN ls -al

# Now let's make the container

FROM openjdk:8-jre-alpine

WORKDIR /contrast
COPY --from=builder /contrast/contrast.jar contrast.jar

WORKDIR /app
COPY target/spring-petclinic-2.3.0.*.jar spring-petclinic.jar


# AUTHENTICATION TO TEAMSERVER

ENV CONTRAST__API__URL=${CONTRAST__API__URL:-https://eval.contrastsecurity.com/Contrast}
ENV CONTRAST__API__API_KEY=${CONTRAST__API__API_KEY}
ENV CONTRAST__API__SERVICE_KEY=${CONTRAST__API__SERVICE_KEY}
ENV CONTRAST__API__USER_NAME=${CONTRAST__API__USER_NAME}


# LOGGING

ENV CONTRAST__AGENT__LOGGER__PATH=/contrast/contrast_agent.log
ENV CONTRAST__AGENT__LOGGER__LEVEL=${CONTRAST__AGENT__LOGGER__LEVEL:-INFO}
ENV CONTRAST__AGENT__LOGGER__ROLL_DAILY=true
ENV CONTRAST__AGENT__LOGGER__BACKUPS=5
ENV CONTRAST__AGENT__SECURITY_LOGGER__PATH=/contrast/contrast_security.log
ENV CONTRAST__AGENT__SECURITY_LOGGER__LEVEL=${CONTRAST__AGENT__LOGGER__LEVEL:-INFO}
ENV CONTRAST__AGENT__SECURITY_LOGGER__ROLL_DAILY=true
ENV CONTRAST__AGENT__SECURITY_LOGGER__BACKUPS=5

ENV CONTRAST__SERVER__ENVIRONMENT=${CONTRAST__SERVER__ENVIRONMENT:-development}
ENV CONTRAST__SERVER__NAME=${CONTRAST__SERVER__NAME:-spring-petclinic-docker}
ENV CONTRAST__APPLICATION__NAME=${CONTRAST__APPLICATION__NAME:-Spring-Petclinic}

CMD java -javaagent:/contrast/contrast.jar -jar spring-petclinic.jar
EXPOSE 8080
