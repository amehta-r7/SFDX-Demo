mvn clean package -Pdeploy -DskipTests

aws s3 cp target/platform-event-listener.jar \
s3://salesforce-platform-event-listener/platform-event-listener.jar

aws lambda update-function-code \
--function-name platform-event-listener \
--s3-bucket salesforce-platform-event-listener \
--s3-key platform-event-listener.jar \
--no-publish