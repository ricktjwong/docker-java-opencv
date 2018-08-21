# docker-java-opencv
Docker image for opencv-3.4.2 (with contrib files) java installation:
  - java version: openjdk-8
  - opencv version: 3.4.2

To test this docker image with circleci, do the following:
  - install circleci and docker locally
  - git clone https://github.com/ricktjwong/pHash.git
  - cd into the directory
  - run circleci build

Note:
  - The opencv lib file (libopencv_java342.so) exists in /opt/opencv-3.4.2/build/lib in the docker image
  - The opencv jar file (opencv-342.jar) exists in /opt/opencv-3.4.2/build/bin in the docker image
  - Using the docker image as the primary container will allow the user to access these files
  - To see a sample config.yml file, look in the pHash repository under /.circleci
  - To run tests that require opencv as a dependency, the following has to be specified in the pom.xml for the java project:
  ```
      <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-surefire-plugin</artifactId>
          <version>2.20.1</version>
          <configuration>
              <argLine>-Djava.library.path=/opt/opencv-3.4.2/build/lib</argLine>
          </configuration>
     </plugin>
     <dependency>
          <groupId>org.opencv</groupId>
          <artifactId>opencv</artifactId>
          <version>3.4.2</version>
     </dependency>
  ```
  - Lines 27-31 can be used as OpenCV has been installed natively into the .m2 file in the docker container
