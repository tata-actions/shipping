FROM maven:3.9.11 AS build
WORKDIR /opt/server
COPY pom.xml .
COPY src ./src 
RUN mvn clean package && \
    mv target/shipping-1.0.jar shipping.jar 

#✅ Why we use JDK in build stage and JRE in final stage

#JDK = JRE + compiler + build tools

#We only need JDK for compiling the code (Maven build stage)

#At runtime, the application only needs JRE
#➡️ Using JRE in final image reduces size drastically
#➡️ This is the idea of multi-stage Docker builds

# here we build maven using jdk = jre + development tools but once once build is over to run we dont need tools 
#so for final image we going with only jre image ---> to reduce final docker image size
# first time we suing chown in in RUN is we after creating /opt/server using WORKDIR 
#we immdiately creating user and giving all permisions of all content tht folder so next next instruction will follow roboshop as owner not the root
#and chown is at COPY INSTRUCTION IS we copying required files from first stage to final image before it will have ownership as root we chaning to roboshop and coping them 
#why we combining all instruction to say all as single RUN to reduce number of layers which result in building image and pushinging image will be fast
FROM eclipse-temurin:17-jre-alpine
WORKDIR /opt/server
RUN addgroup -S roboshop && adduser -S roboshop -G roboshop && \
    chown -R roboshop:roboshop /opt/server
ENV CART_ENDPOINT="cart:8080" \
    DB_HOST="mysql"
EXPOSE 8080
LABEL project="roboshop" \
      Trianer="vigi"    
COPY --from=build --chown=roboshop:roboshop /opt/server/shipping.jar /opt/server
USER roboshop
ENTRYPOINT ["java","-jar","shipping.jar"] 



#FROM maven:3.9.11
#WORKDIR /opt/server
#COPY pom.xml .
#COPY src ./src 
# to have the exact same src folder structure

#RUN mvn clean package 
#RUN mv target/shipping-1.0.jar shipping.jar 

# down we giving just cart it will take cart conatiner IP becuse IP will change everytime we going with it
#ENV CART_ENDPOINT="cart:8080" \
 #   DB_HOST="mysql"
#CMD ["java","-jar","shipping.jar"]    