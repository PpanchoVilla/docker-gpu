# Docker GPU Guide - Kompletní návod

## 🚀 Spuštění Docker kontejneru s GPU podporou

### 1. Spuštění kontejneru
```bash
# Zastavit všechny běžící kontejnery
sudo docker compose down

# Spustit kontejner s GPU podporou
sudo docker compose up -d app

# Zkontrolovat, že kontejner běží
sudo docker ps
```

### 2. Kontrola GPU dostupnosti
```bash
# Zkontrolovat GPU v kontejneru
sudo docker exec -it tf-gpu nvidia-smi

# Zkontrolovat NVIDIA zařízení
sudo docker exec -it tf-gpu ls -la /dev/nvidia*
```

## 🔧 Připojení k Docker kontejneru

### Jako root (pro instalace a konfiguraci)
```bash
sudo docker exec -it --user root tf-gpu bash
```

### Jako developer (pro běžnou práci)
```bash
sudo docker exec -it tf-gpu bash
```

## 🐍 TensorFlow GPU - Řešení problému s virtualním prostředím

### Problém: TensorFlow funguje systémově, ale venv nemá přístup

### Řešení 1: Použít systémový Python pro TensorFlow
```bash
# V kontejneru jako root
cd /workspace

# Spustit Python se systémovými balíčky
python3

# V Python konzoli:
import tensorflow as tf
print("TensorFlow version:", tf.__version__)
print("GPU available:", tf.config.list_physical_devices('GPU'))

# Test GPU
a = tf.constant([1, 2, 3])
print("Tensor device:", a.device)
```

### Řešení 2: Nainstalovat TensorFlow do venv
```bash
# V kontejneru jako root
cd /workspace
source venv/bin/activate

# Nainstalovat TensorFlow do venv
pip install tensorflow[and-cuda]==2.18.* --break-system-packages

# Test
python3 -c "import tensorflow as tf; print('TensorFlow in venv:', tf.__version__)"
```

### Řešení 3: Hybridní přístup (doporučeno)
```bash
# V kontejneru jako root
cd /workspace

# Nainstalovat potřebné moduly systémově
pip install yfinance --break-system-packages
pip install matplotlib --break-system-packages
pip install pandas --break-system-packages

# Spustit skript se systémovým Pythonem
python3 agent.py
```

## 📦 Instalace modulů pro skripty

### Systémová instalace (doporučeno pro TensorFlow)
```bash
# V kontejneru jako root
pip install nazev_modulu --break-system-packages

# Příklady:
pip install yfinance --break-system-packages
pip install scikit-learn --break-system-packages
pip install matplotlib --break-system-packages
```

### Instalace do venv (pro ostatní moduly)
```bash
# V kontejneru jako root
cd /workspace
source venv/bin/activate

# Nainstalovat do venv
pip install nazev_modulu

# Deaktivovat venv
deactivate
```

## 🌐 JupyterLab pro root uživatele

### Spuštění JupyterLab jako root
```bash
# V kontejneru jako root
cd /workspace

# Spustit JupyterLab
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password=''
```

### Přístup k JupyterLab
- **URL:** http://localhost:8888
- **Token:** není potřeba (zakázán)
- **Heslo:** není potřeba (zakázáno)

### Alternativně - spuštění v pozadí
```bash
# V kontejneru jako root
cd /workspace
nohup jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' > jupyter.log 2>&1 &
```

## 🔍 Diagnostika GPU problémů

### Kontrola CUDA
```bash
# V kontejneru
nvidia-smi
nvcc --version  # pokud je dostupný
```

### Kontrola TensorFlow GPU
```bash
# V kontejneru
python3 -c "
import tensorflow as tf
print('TensorFlow version:', tf.__version__)
print('GPU available:', tf.config.list_physical_devices('GPU'))
print('CUDA built:', tf.test.is_built_with_cuda())
print('GPU built:', tf.test.is_built_with_gpu_support())
"
```

### Test GPU výpočtů
```bash
# V kontejneru
python3 -c "
import tensorflow as tf
with tf.device('/GPU:0'):
    a = tf.constant([1, 2, 3])
    b = tf.constant([4, 5, 6])
    c = tf.add(a, b)
    print('Result:', c.numpy())
    print('Device:', c.device)
"
```

## 🛠️ Časté problémy a řešení

### Problém: "No module named tensorflow"
```bash
# Řešení: Nainstalovat TensorFlow systémově
pip install tensorflow[and-cuda]==2.18.* --break-system-packages
```

### Problém: "externally-managed-environment"
```bash
# Řešení: Použít --break-system-packages
pip install nazev_modulu --break-system-packages
```

### Problém: GPU není dostupné
```bash
# Kontrola environment variables
echo $CUDA_VISIBLE_DEVICES
echo $NVIDIA_VISIBLE_DEVICES

# Restart kontejneru
sudo docker compose down && sudo docker compose up -d app
```

### Problém: CUDA inicializace selhává
```bash
# Zkontrolovat DRI zařízení
ls -la /dev/dri/

# Pokud chybí, vytvořit
sudo mknod /dev/dri/card0 c 226 0
sudo chown root:video /dev/dri/card0
```

## 📋 Užitečné příkazy

### Kontrola stavu
```bash
# Stav kontejnerů
sudo docker ps

# Logy kontejneru
sudo docker logs tf-gpu

# Použití kontejneru
sudo docker exec -it tf-gpu bash
```

### Monitoring výkonu
```bash
# GPU monitoring
sudo docker exec -it tf-gpu nvitop

# CPU/Memory monitoring
sudo docker exec -it tf-gpu htop
```

### Zálohování workspace
```bash
# Zálohovat workspace
sudo docker cp tf-gpu:/workspace ./workspace_backup

# Obnovit workspace
sudo docker cp ./workspace_backup tf-gpu:/workspace
```

## 🎯 Doporučený workflow

1. **Spustit kontejner:** `sudo docker compose up -d app`
2. **Připojit se jako root:** `sudo docker exec -it --user root tf-gpu bash`
3. **Instalovat moduly systémově:** `pip install nazev_modulu --break-system-packages`
4. **Spustit JupyterLab jako root:** `jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser`
5. **Otevřít prohlížeč:** http://localhost:8888
6. **Pracovat s TensorFlow GPU v JupyterLab**

## 🔧 Environment Variables (docker-compose.yml)

```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=all
  - NVIDIA_DRIVER_CAPABILITIES=all
  - CUDA_VISIBLE_DEVICES=0
  - CUDA_HOME=/usr/local/cuda
  - LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/cuda/lib64
  - TF_CPP_MIN_LOG_LEVEL=0
  - TF_FORCE_GPU_ALLOW_GROWTH=true
```

---

**Poznámka:** Pokud GPU TensorFlow stále nefunguje, pravděpodobně běží pouze CPU režim, ale to je často dostačující pro většinu úloh.
