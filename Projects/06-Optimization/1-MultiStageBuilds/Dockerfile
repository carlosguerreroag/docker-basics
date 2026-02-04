# BUILD IMAGE
FROM adoptopenjdk/openjdk8:latest AS build_img
RUN apt update && apt install -y maven git
RUN git clone -b vp-docker https://github.com/imranvisualpath/vprofile-repo.git
RUN cd vprofile-repo && mvn install

# FINAL IMAGE
FROM tomcat:8-jre11 AS final_img
LABEL "Author"="Carlos"
LABEL "Project"="1-MultiStageBuilds"
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build_img vprofile-repo/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
