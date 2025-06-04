# ARM64 Docker镜像构建说明

本项目已配置了专门的GitHub Actions workflow用于构建ARM64架构的Docker镜像，构建完成后通过GitHub Actions Artifacts提供下载。

## 🚀 构建方式

### 自动触发构建
当您推送新的git标签时，workflow会自动触发构建：
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 手动触发构建
您也可以在GitHub仓库的Actions页面手动触发构建：
1. 进入仓库的Actions页面
2. 选择"Build ARM64 Docker Image"workflow
3. 点击"Run workflow"
4. 可选择自定义镜像标签名称（默认为latest）

## 📦 镜像下载

构建完成后，您可以通过以下步骤下载和使用ARM64镜像：

### 1. 下载镜像文件
1. 进入GitHub仓库的Actions页面
2. 找到相应的workflow运行记录
3. 在"Artifacts"部分下载镜像文件（格式：`xinference-{tag}-docker-image`）

### 2. 加载和使用镜像
```bash
# 解压镜像文件
gunzip xinference-v1.0.0-cpu-arm64.tar.gz

# 加载镜像到Docker
docker load < xinference-v1.0.0-cpu-arm64.tar

# 运行容器
docker run -it xinference:v1.0.0-cpu-arm64
```

### 镜像标签命名规则
- 基于git标签：`xinference:{tag}-cpu-arm64`（如：`xinference:v1.0.0-cpu-arm64`）
- 手动构建：`xinference:{custom-tag}-cpu-arm64`
- 默认：`xinference:latest-cpu-arm64`

## 🔧 技术特性

- **多架构支持**: 专门为ARM64架构优化
- **基于CPU**: 使用cpu.Dockerfile构建，适合ARM64 CPU环境
- **缓存优化**: 使用GitHub Actions缓存加速构建过程
- **离线分发**: 通过GitHub Actions Artifacts提供镜像文件下载
- **压缩存储**: 镜像文件经过gzip压缩，节省存储空间和下载时间
- **自动化**: 完全自动化的构建流程

## 📋 构建配置

- **Dockerfile**: `xinference/deploy/docker/cpu.Dockerfile`
- **平台**: `linux/arm64`
- **构建时间**: 约120-180分钟
- **缓存**: GitHub Actions缓存
- **存储**: GitHub Actions Artifacts（保留30天）
- **压缩**: gzip压缩

## 🛡️ 安全配置

由于不再推送到Docker Hub，您不需要配置Docker Hub相关的Secrets。GitHub Actions会自动处理artifact的上传和下载。

## 📝 注意事项

- 镜像文件通过GitHub Actions Artifacts提供，保留期为30天
- 其他workflow（Python CI、Release、原Docker CD等）已被暂时禁用，专注于ARM64镜像构建
- 构建过程使用QEMU模拟ARM64环境
- 支持构建缓存以提高后续构建速度
- 镜像文件经过gzip压缩，下载后需要解压
- 镜像标签格式：`xinference:{version}-cpu-arm64`

## 🔄 恢复其他Workflow

如需重新启用其他workflow，请取消注释以下文件中的相关内容：
- `.github/workflows/docker-cd.yaml`
- `.github/workflows/release.yaml`
- `.github/workflows/python.yaml`
- `.github/workflows/assign.yaml`
- `.github/workflows/issue.yaml`

## 💡 使用示例

```bash
# 1. 从GitHub Actions下载镜像文件（通过浏览器）
# 文件名示例: xinference-v1.0.0-cpu-arm64-docker-image.zip

# 2. 解压下载的zip文件
unzip xinference-v1.0.0-cpu-arm64-docker-image.zip

# 3. 解压Docker镜像文件
gunzip xinference-v1.0.0-cpu-arm64.tar.gz

# 4. 加载镜像到Docker
docker load < xinference-v1.0.0-cpu-arm64.tar

# 5. 验证镜像已加载
docker images | grep xinference

# 6. 运行容器
docker run -it xinference:v1.0.0-cpu-arm64 /bin/bash
``` 