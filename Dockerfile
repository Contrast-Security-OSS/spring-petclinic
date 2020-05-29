
# Builder
#
# The petclinic jar will be built in AzDO prior. Ideally, I'll also separate the build pipeline from the release pipeline. We'll see.
# But the goal here is only to bring in the Contrast agent at this time.

FROM openjdk:8-jre-alpine

WORKDIR /contrast
COPY contrast.jar contrast.jar

WORKDIR /app
COPY target/spring-petclinic*.jar spring-petclinic.jar


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

LABEL TEST_LABEL=TEST
