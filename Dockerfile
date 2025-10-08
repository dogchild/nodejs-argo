# 第一阶段：构建阶段
FROM node:lts-slim AS builder

WORKDIR /app

# 先复制依赖文件，利用Docker缓存
COPY package*.json ./

# 安装生产环境依赖
RUN npm install --only=production

# 第二阶段：运行阶段
FROM node:lts-slim

# 设置时区（可选，根据需要调整）
ENV TZ=Asia/Shanghai
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

# 创建非root用户
RUN groupadd -g 1001 nodejs && \
    useradd -u 1001 -g nodejs -m node-app

WORKDIR /app

# 从构建阶段复制依赖
COPY --from=builder /app/node_modules ./node_modules

# 复制应用文件
COPY index.js .
COPY package.json .

# 创建并设置tmp目录权限（默认的FILE_PATH）
RUN mkdir -p /app/tmp && \
    chown -R node-app:nodejs /app && \
    chmod -R 755 /app/tmp && \
    chmod +x index.js

# 切换到非root用户
USER node-app

# 设置默认端口
ENV PORT 3005

# 暴露端口
EXPOSE $PORT

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node -e "http.get('http://localhost:' + (process.env.SERVER_PORT || process.env.PORT || 3005), (res) => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

# 设置启动命令
CMD ["node", "index.js"]
