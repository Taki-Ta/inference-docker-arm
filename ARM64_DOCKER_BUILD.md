# ARM64 Docker镜像构建说明

本项目已配置了专门的GitHub Actions workflow用于构建ARM64架构的Docker镜像，构建完成后通过GitHub Actions Artifacts提供下载。

## 🔧 已解决的依赖冲突问题

我们已经优化了ARM64构建，解决了以下问题：
- ✅ 移除了GPU专用的量化库（`autoawq`, `gptqmodel`, `bitsandbytes`）
- ✅ 移除了可能在ARM64上有兼容性问题的包（`tensorizer`）  
- ✅ 优化了torch版本冲突（从requirements中移除重复的torch安装）
- ✅ 改进了pip安装策略，采用分步安装减少依赖冲突
- ✅ 添加了错误容错处理（如xllamacpp安装失败时继续构建）

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

# 或指定端口运行服务
docker run -p 9997:9997 xinference:v1.0.0-cpu-arm64 xinference --host 0.0.0.0 --port 9997
```

### 镜像标签命名规则
- 基于git标签：`xinference:{tag}-cpu-arm64`（如：`xinference:v1.0.0-cpu-arm64`）
- 手动构建：`xinference:{custom-tag}-cpu-arm64`（如：`xinference:latest-cpu-arm64`）

## 🔧 技术特性

- **ARM64优化**: 专门为ARM64/AArch64架构优化
- **CPU专用**: 使用cpu.Dockerfile构建，移除GPU依赖
- **依赖优化**: 移除冲突的量化库和ARM64不兼容的包
- **容错构建**: 对可选组件采用容错安装策略
- **缓存优化**: 使用GitHub Actions缓存加速构建过程
- **离线分发**: 通过GitHub Actions Artifacts提供离线镜像下载
- **压缩存储**: 自动gzip压缩，节省存储和传输

## 📋 构建配置

- **Dockerfile**: `xinference/deploy/docker/cpu.Dockerfile`
- **基础镜像**: `continuumio/miniconda3:23.10.0-1`
- **Python版本**: 3.x（由miniconda提供）
- **PyTorch**: CPU版本，通过专用索引安装
- **架构**: linux/arm64

## 🛠️ 依赖说明

### 已移除的GPU专用包
这些包在ARM64 CPU环境下不兼容或不必要：
- `autoawq` - GPU量化库
- `gptqmodel` - GPU量化库  
- `bitsandbytes` - CUDA专用量化库
- `tensorizer` - 可能在ARM64上有兼容性问题

### 保留的核心功能
- ✅ 基础推理能力
- ✅ 文本生成模型
- ✅ 嵌入模型
- ✅ 多模态模型
- ✅ GGUF格式支持
- ✅ transformers生态

## 🐛 故障排除

### 构建失败
如果构建失败，请检查：
1. requirements文件中是否有新的冲突依赖
2. 基础镜像是否支持ARM64
3. 网络连接是否稳定

### 运行时问题
如果镜像运行时遇到问题：
1. 检查Docker是否支持ARM64
2. 确认主机架构为ARM64
3. 查看容器日志获取详细错误信息

## 📈 性能建议

- **内存**: 建议至少8GB RAM用于运行中等大小的模型
- **存储**: 模型文件通常较大，确保有足够的磁盘空间
- **网络**: 首次运行时需要下载模型，建议使用稳定的网络连接

## 💡 完整使用示例

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

# 6. 运行服务
docker run -d -p 9997:9997 \
  --name xinference-server \
  xinference:v1.0.0-cpu-arm64 \
  xinference --host 0.0.0.0 --port 9997

# 7. 检查服务状态
docker logs xinference-server
curl http://localhost:9997/v1/models
```

## 📝 重要说明

- **存储期限**: GitHub Actions Artifacts保留30天
- **其他Workflow**: 其他workflow已被暂时禁用，专注于ARM64构建
- **跨平台模拟**: 使用QEMU在x86_64上模拟ARM64环境进行构建
- **缓存策略**: 支持多层缓存以提高构建速度
- **镜像格式**: 标准Docker tar格式，经过gzip压缩

## 🔄 恢复其他Workflow

如需重新启用其他workflow，请取消注释以下文件中的相关内容：
- `.github/workflows/docker-cd.yaml`
- `.github/workflows/release.yaml`  
- `.github/workflows/python.yaml`
- `.github/workflows/assign.yaml`
- `.github/workflows/issue.yaml`

## 🔗 相关链接

- [GitHub Actions Workflow](/.github/workflows/docker-arm64.yaml)
- [原始CPU Dockerfile](/xinference/deploy/docker/cpu.Dockerfile)  
- [依赖文件](/xinference/deploy/docker/)
- [项目主页](https://github.com/xorbitsai/xinference) 