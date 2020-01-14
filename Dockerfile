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

COPY build.sbt $PROJECT_HOME/activator/build.sbt
#build
WORKDIR /app
COPY project /app/project
COPY app /app/app
#RUN $PROJECT_HOME/activator/activator compile

RUN $PROJECT_HOME/activator/activator -help
RUN $PROJECT_HOME/activator/activator clean compile universal:package-bin


ARG port="80"
ENV PORT=$port
EXPOSE $PORT

ARG jvm_heap_size="512m"
ENV JVM_HEAP_SIZE=$jvm_heap_size

VOLUME /logs

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ARG target="app_build" 
COPY $target/contentengine-avengers /app

ENTRYPOINT ["/docker-entrypoint.sh"]
