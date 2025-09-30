# TensorFlow GPU + Jupyter + nvitop-exporter (Ubuntu 24.04, CUDA 12.6)

Tento build poskytuje prostředí pro TF2 na GPU NVIDIA s JupyterLab, nvitop-exporter (Prometheus), a volitelným Syncthing.

## Základní info
- Base: `nvidia/cuda:12.6.2-cudnn-runtime-ubuntu24.04`
- Python: z Ubuntu 24.04 + pip
- TensorFlow: 2.18.x (pip wheel s cu12)
- CUDA/cuDNN: cu12 toolkity z wheelů; base image obsahuje runtime + cuDNN
- GPU target: RTX 3050 Ti, RTX 4090, A100 (driver >= 550 doporučen)

## Požadavky na hostiteli
- NVIDIA ovladač kompatibilní s CUDA 12 (doporučeno 550+)
- NVIDIA Container Toolkit (`nvidia-docker2` / runtime=nvidia)
- Docker Compose v2

## Build a run
```bash
# build
docker compose build

# run (Jupyter: http://localhost:8888)
docker compose up -d app

# logs
docker compose logs -f app
```

## Porty
- JupyterLab: 8888
- nvitop-exporter (Prometheus): 9000 (endpoint /metrics)
- Syncthing (separátní služba): GUI 8384, sync: 22000/TCP+UDP, discovery: 21027/UDP

## Prometheus scrape
```yaml
- job_name: nvitop
  static_configs:
    - targets: ["localhost:9000"]
```
Grafana dashboard: https://grafana.com/grafana/dashboards/22589-nvitop-dashboard/

## Syncthing volby
Základní Syncthing je k dispozici přímo v kontejneru (program `syncthing`) a také jako separátní služba v `docker-compose.yml` (doporučeno používat separátní službu `syncthing`).

## Upozornění k verzím
- Pokud chcete jiné verze CUDA/TF, upravte base image tag a pip balíčky v `Dockerfile`.
- Pro TF nightly lze použít `pip install tf-nightly` a vynechat pin TF.

## Bezpečnost
- Jupyter je spouštěn bez tokenu/hesla pro lokální vývoj. Před nasazením nastavte autentizaci (např. `JUPYTER_TOKEN`).

## Useful
V kontejneru jsou dostupné nástroje: `nvitop`, `nvidia-smi`, `tensorboard`.
