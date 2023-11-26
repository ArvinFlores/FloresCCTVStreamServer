import os
import json

# Get cpu utilization as percentage
def get_cpu_util():
  return os.popen("echo $((100-$(vmstat 1 2|tail -1|awk '{print $15}')))%").readline().strip()

# Get the available disk space in GB
def get_disk_space():
  return os.popen("echo $(df -h / | tail -1 | awk '{print $4}')").readline().strip()

# Get the available memory in GB
def get_avail_mem():
  mb = os.popen("echo $(free --mega | head -2 | tail -1 | awk '{print $4}')").readline()
  return f'{int(mb) / 1000}G'

# Get cpu temp in farenheit
def get_cpu_temp():
  temp = os.popen('cat /sys/class/thermal/thermal_zone0/temp').readline()
  celc = int(temp) / 1000
  f = round((celc * 9/5) + 32, 1)
  return f'{f}F'

# Get the gpu temp in farenheit
def get_gpu_temp():
  temp = os.popen("echo $(vcgencmd measure_temp | grep  -o -E '[[:digit:]].*')").readline().replace("'C", "")
  f = round((float(temp) * 9/5) + 32, 1)
  return f'{f}F'

# Get the ip address of the host
def get_ip_addr():
  return os.popen("hostname -I | awk '{print $1}'").readline().strip()

data = {
  "ip": get_ip_addr(),
  "cpu_utilization": get_cpu_util(),
  "available_disk_space": get_disk_space(),
  "available_memory": get_avail_mem(),
  "cpu_temp": get_cpu_temp(),
  "gpu_temp": get_gpu_temp()
}

with open("build/health.json", "w") as file:
  file.write(json.dumps(data, indent=2))
