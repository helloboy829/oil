# 多阶段构建 - 第一阶段：构建应用
FROM maven:3.8.1-openjdk-11 AS build
WORKDIR /build

# 复制pom.xml并下载依赖（利用Docker缓存层）
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 复制源代码并构建
COPY src ./src
RUN mvn clean package -DskipTests

# 第二阶段：运行应用
FROM openjdk:11-jre-slim
WORKDIR /app

# 从构建阶段复制jar包
COPY --from=build /build/target/*.jar app.jar

# 创建 qrcodes 目录
RUN mkdir -p /app/qrcodes

# 暴露端口
EXPOSE 8080

# 设置 JVM 参数
ENV JAVA_OPTS="-Xms256m -Xmx512m -Djava.security.egd=file:/dev/./urandom"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
