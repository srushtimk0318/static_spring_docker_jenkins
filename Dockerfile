FROM tomcat:9-jdk17
LABEL maintainer="sareenakashi1221@gmail.com"
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY target/devguru-0.0.1-SNAPSHOT.jar /usr/local/tomcat/webapps/app.jar
EXPOSE 8084
CMD ["catalina.sh", "run"]

    
