# CF-Hero Docker 部署指南

## 快速开始

### 1. 准备工作

创建必要的目录结构：
```bash
mkdir -p config input output
```

### 2. 配置API密钥

创建配置文件 `config/cf-hero.yaml`：
```yaml
zoomeye:
  - "your_zoomeye_api_key"
securitytrails:
  - "your_securitytrails_api_key"
shodan:
  - "your_shodan_api_key"
censys:
  - "your_censys_api_key"
```

### 3. 准备目标文件

在 `input` 目录下创建域名列表文件，例如 `domains.txt`：
```
https://example.com
https://target1.com
https://target2.com
```

## 部署方式

### 方式一：使用 Docker Compose（推荐）

#### 构建并启动服务
```bash
# 构建镜像
docker-compose build

# 运行基本扫描
docker-compose run --rm cf-hero -f input/domains.txt

# 使用所有第三方服务进行扫描
docker-compose run --rm cf-hero -f input/domains.txt -zoomeye -censys -shodan -securitytrails

# 仅显示在Cloudflare后面的域名
docker-compose run --rm cf-hero -f input/domains.txt -cf

# 子域名扫描
docker-compose run --rm cf-hero -td https://target.com -dl input/subdomains.txt
```

#### 后台运行
```bash
# 启动服务（后台运行）
docker-compose up -d

# 查看日志
docker-compose logs -f cf-hero

# 停止服务
docker-compose down
```

### 方式二：直接使用 Docker

#### 构建镜像
```bash
docker build -t cf-hero:latest .
```

#### 运行容器
```bash
# 基本运行
docker run --rm \
  -v $(pwd)/config:/home/cfhero/.config \
  -v $(pwd)/input:/home/cfhero/input \
  -v $(pwd)/output:/home/cfhero/output \
  cf-hero:latest -f input/domains.txt

# 使用所有服务进行扫描
docker run --rm \
  -v $(pwd)/config:/home/cfhero/.config \
  -v $(pwd)/input:/home/cfhero/input \
  -v $(pwd)/output:/home/cfhero/output \
  cf-hero:latest -f input/domains.txt -zoomeye -censys -shodan -securitytrails

# 交互式运行
docker run -it --rm \
  -v $(pwd)/config:/home/cfhero/.config \
  -v $(pwd)/input:/home/cfhero/input \
  -v $(pwd)/output:/home/cfhero/output \
  cf-hero:latest /bin/sh
```

## 常用命令示例

### 基础扫描
```bash
# 从文件读取域名进行扫描
docker-compose run --rm cf-hero -f input/domains.txt

# 启用详细输出
docker-compose run --rm cf-hero -f input/domains.txt -v

# 设置工作线程数
docker-compose run --rm cf-hero -f input/domains.txt -w 32
```

### 使用第三方服务
```bash
# 使用ZoomEye
docker-compose run --rm cf-hero -f input/domains.txt -zoomeye

# 使用多个服务
docker-compose run --rm cf-hero -f input/domains.txt -zoomeye -censys -shodan

# 使用所有服务
docker-compose run --rm cf-hero -f input/domains.txt -zoomeye -censys -shodan -securitytrails
```

### 域名分类
```bash
# 只显示在Cloudflare后面的域名
docker-compose run --rm cf-hero -f input/domains.txt -cf

# 只显示不在Cloudflare后面的域名
docker-compose run --rm cf-hero -f input/domains.txt -non-cf
```

### 子域名扫描
```bash
# 使用子域名列表扫描目标域名
docker-compose run --rm cf-hero -td https://target.com -dl input/subdomains.txt
```

### 自定义配置
```bash
# 使用代理
docker-compose run --rm cf-hero -f input/domains.txt -px "http://proxy:8080"

# 自定义User-Agent
docker-compose run --rm cf-hero -f input/domains.txt -ua "Custom-Agent/1.0"

# 指定HTML标题
docker-compose run --rm cf-hero -f input/domains.txt -title "Expected Title"
```

## 管道使用

```bash
# 从标准输入读取
echo "https://example.com" | docker run -i --rm \
  -v $(pwd)/config:/home/cfhero/.config \
  cf-hero:latest

# 结合其他工具使用
cat input/domains.txt | docker run -i --rm \
  -v $(pwd)/config:/home/cfhero/.config \
  cf-hero:latest -zoomeye -censys
```

## 故障排除

### 常见问题

1. **API密钥问题**
   - 确保 `config/cf-hero.yaml` 文件格式正确
   - 检查API密钥是否有效

2. **权限问题**
   - 确保配置和输入目录有正确的读写权限
   ```bash
   chmod -R 755 config input output
   ```

3. **网络问题**
   - 如果需要使用代理，在docker-compose.yml中配置环境变量
   - 检查防火墙设置

### 调试模式

```bash
# 启用详细输出
docker-compose run --rm cf-hero -f input/domains.txt -v

# 进入容器调试
docker-compose run --rm --entrypoint /bin/sh cf-hero
```

## 安全注意事项

1. **API密钥安全**
   - 不要将包含真实API密钥的配置文件提交到版本控制系统
   - 使用环境变量或密钥管理系统

2. **网络安全**
   - 在生产环境中使用适当的网络隔离
   - 考虑使用VPN或代理

3. **合规使用**
   - 仅用于授权的安全测试
   - 遵守相关法律法规和道德准则

## 性能优化

1. **资源限制**
   ```yaml
   # 在docker-compose.yml中添加资源限制
   deploy:
     resources:
       limits:
         cpus: '2.0'
         memory: 1G
       reservations:
         cpus: '1.0'
         memory: 512M
   ```

2. **并发控制**
   ```bash
   # 调整工作线程数
   docker-compose run --rm cf-hero -f input/domains.txt -w 64
   ``` 