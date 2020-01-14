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
# COPY activator $PROJECT_HOME/activator/activator
# COPY activator-launch-1.2.3.jar $PROJECT_HOME/activator/activator-launch-1.2.3.jar
# COPY project $PROJECT_HOME/activator/project
RUN wget http://downloads.typesafe.com/typesafe-activator/1.3.10/typesafe-activator-1.3.10.zip && \
    unzip typesafe-activator-1.3.10.zip
ENV PATH $PROJECT_HOME/activator/activator-dist-1.3.10/bin:$PATH

COPY build.sbt build.sbt
RUN activator compile


FROM bulider

# COPY ivy & sbt
COPY --from=bulider  /root/.sbt /root/.sbt
COPY --from=bulider /root/.ivy2 /root/.ivy2

WORKDIR /app
COPY build.sbt build.sbt
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
