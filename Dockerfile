# extend base ubuntu
FROM openjdk:8 as bulider

MAINTAINER MindTickle, https://github.com/MindTickle

# install dependencies for awslogs
RUN apt-get update && \
    apt-get install -y python-dev python-pip cron

ENV PROJECT_HOME /usr/src
RUN mkdir -p $PROJECT_HOME/activator $PROJECT_HOME/app
WORKDIR $PROJECT_HOME/activator

# for now
COPY activator $PROJECT_HOME/activator/activator
COPY activator-launch-1.2.3.jar $PROJECT_HOME/activator/activator-launch-1.2.3.jar
COPY project $PROJECT_HOME/activator/project

COPY build.sbt $PROJECT_HOME/activator/build.sbt
RUN $PROJECT_HOME/activator/activator compile


FROM bulider

# COPY ivy & sbt
COPY --from=bulider  /root/.sbt /root/.sbt
COPY --from=bulider /root/.ivy2 /root/.ivy2

WORKDIR /app

COPY . /app

ARG port="80"
ENV PORT=$port
EXPOSE $PORT

ARG jvm_heap_size="512m"
ENV JVM_HEAP_SIZE=$jvm_heap_size

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

RUN $PROJECT_HOME/activator/activator clean compile dist

RUN cp target/universal/play-scala-starter-example-1.0-SNAPSHOT.zip /app && unzip play-scala-starter-example-1.0-SNAPSHOT.zip

ENTRYPOINT ["/docker-entrypoint.sh"]