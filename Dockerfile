# 多阶段构建Dockerfile for CF-Hero
# 第一阶段：构建阶段
FROM golang:1.20-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的工具
RUN apk add --no-cache git ca-certificates tzdata

# 复制go mod文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o cf-hero ./cmd/cf-hero

# 第二阶段：运行阶段
FROM alpine:latest

# 安装必要的工具
RUN apk --no-cache add ca-certificates tzdata

# 创建非root用户
RUN addgroup -g 1001 -S cfhero && \
    adduser -u 1001 -S cfhero -G cfhero

# 设置工作目录
WORKDIR /home/cfhero

# 从构建阶段复制二进制文件
COPY --from=builder /app/cf-hero .

# 创建配置目录和默认域名文件
RUN mkdir -p .config && \
    echo "https://baidu.com" > domains.txt && \
    echo "https://github.com" >> domains.txt

# 设置权限
RUN chown -R cfhero:cfhero /home/cfhero

# 切换到非root用户
USER cfhero

# 默认行为：如果没有命令，显示帮助；如果有命令，执行命令
CMD ["./cf-hero", "--help"] 