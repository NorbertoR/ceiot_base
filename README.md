# CEIOT BASE
Cambio yo para SSH

Código para ejemplo básico de IoT


![](./img/arch.png)

Lo siguiente se puede hacer en cualquier sistema de virtualización por comodidad y prolijidad o directamente en una máquina real.


## Paso 1: VM con virtualbox

  - CPUs    : 1
  - Memoria : 4 GB 
  - Disco   : 40 GB (llega a ocupar casi 20GB)
  - Network : bridge
  - Distro  : Ubuntu Server 20.04.4 LTS

Finalizado el proceso de instalación, quizás con 2GB o incluso 1.5 GB de RAM alcance sin firefox.

### Instalación

    # Bajar el instalador de https://ubuntu.com/download/server.
    # Crear una nueva VM.
    # Parametrizar según los valores previos
    # Al arrancar, va a preguntar de dónde, darle la ruta a la ISO descargada.
    # Si ofrece "Update to the new installer", no, gracias.
    # Al cargar el primer usuario, mejor ponerle nombre "iot"
    # Varios "Done".
    # Cuando ofrece instalar openssh server, aceptarlo.
    # Si se queda para siempre en "downloading and installing security updates", "cancel update and reboot".
    # "reboot now"
    
### Ajustes

    # Apretar enter, hacer login.
    # firefox opcional, ocupa como 300MB
    sudo apt install xorg openbox firefox git gcc make perl 
    # En el menú de VirtualBox asociado a la instancia actual
    # Devices -> Insert guest additions CD image...
    sudo mount /dev/cdrom /mnt
    sudo /mnt/VBoxLinuxAdditions.run
    # Si dice que no existe /dev/cdrom
    sudo /media/${USER}/VBoxLinuxAdditions.run
    # paciencia...
    # En una terminal
    sudo addgroup "$USER" vboxsf
    sudo addgroup "$USER" dialout
    sudo reboot

### Espacio libre

Por algún motivo que ignoro, la instalación no usa todo el espacio disponible, se corrige en cualquier momento con:

      $ sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
      $ sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

## Paso 2: API/SPA

### Instalación node + typescript

    curl -sL https://deb.nodesource.com/setup_17.x | sudo -E bash -
    sudo apt install nodejs
    node --version
    #Debe ser 17.x.x, en caso contrario el paso con curl falló
    sudo npm install typescript -g

### Código referencia

    mkdir ~/esp
    cd ~/esp    
    git clone https://github.com/cpantel/ceiot_base.git
    cd ceiot_base/api
    npm install; # express body-parser mongodb-memory-server mongodb pg-mem

### Pruebas

En una terminal servidor API:

    cd ~/esp/ceiot_base/api
    node index.js
    
Esperamos:

    mongo measurement database Up
    sql device database up
    Listening at 8080

En otra terminal, servidor SPA:

    cd ~/esp/ceiot_base/api/spa
    ./rebuild.sh
    
Esperamos:

    Starting compilation in watch mode...
    Found 0 errors. Watching for file changes.
    
Cliente, en otra terminal:

    cd ~/esp/ceiot_base/tools
    ./get_color_devices.sh 14
    
Esperamos:
    
![](./img/API_color.png)


En un navegador, probar las siguientes URLs:


    SPA: http://localhost:8080/index.html -> lista de dispositivos con un botón de refrescar

![](./img/SPA_devices.png)
    
    WEB: http://localhost:8080/web/device -> lista de dispositivos web
    
![](./img/WEB_device.png)
    
    API: http://localhost:8080/device -> lista dispositivos JSON

![](./img/API_device.png)

## Paso 3: Entorno ESP-IDF para ESP32/ESP32s2/ESP32c3

En el último paso, alcanza con elegir sólo las que uno tiene.

    sudo apt install git wget flex bison gperf python3 python3-pip python3-setuptools cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 
    cd ~/esp
    git clone https://github.com/UncleRus/esp-idf-lib.git
    git clone -b v4.4 --recursive https://github.com/espressif/esp-idf.git
    cd ~/esp/esp-idf-lib
    git checkout 0.8.2
    cd ~/esp/esp-idf
    git checkout release/v4.4
    git submodule update --init --recursive
    # según tengas esp32, esp32c3 o esp32s2:
    ./install.sh esp32
    ./install.sh esp32c3
    ./install.sh esp32s2
    # pueden ir juntos en una sola línea, sin espacios, por ejemplo:
    ./install.sh esp32,esp32c3,esp32s2

Relato informal de la experiencia de exploración:

[Ejemplo de ESP32 con lectura de DHT11](https://seguridad-agile.blogspot.com/2022/02/ejemplo-de-esp32-con-lectura-de-dht11.html)

[Primer contacto con ESP32](https://seguridad-agile.blogspot.com/2022/02/primer-contacto-con-esp32.html)

### Cada microcontrolador

Las siguientes instrucciones implican que en la terminal actual se ha ejecutado:

    cd ~/esp/esp-idf
    . ./export.sh


#### ESP32

Dependiendo del modelo, puede hacer falta oprimir los botones para el paso **flash**:

##### Receta 1 (comprobada por docente)

   Executing action: flash
   Serial port /dev/ttyUSB0
   Connecting...........**RESET**
   Detecting chip type... Unsupported detection protocol, switching and trying again...
   Connecting....
   Detecting chip type... ESP32
   ...
   esptool.py v3.3-dev
   Serial port /dev/ttyUSB0
   Connecting...............**RESET**
   Chip is ESP32-D0WDQ6 (revision 1)
   Features: WiFi, BT, Dual Core, 240MHz, VRef calibration in efuse, Coding Scheme None
   ...

##### Receta 2 (tomada de https://youtu.be/Jt6ZDct4bZk?t=912, al docente no le funcionó)

   apretar y mantener **RESET** 
   apretar y soltar **BOOT**
   soltar **RESET**

##### Monitor

   Executing action: monitor
   Serial port /dev/ttyUSB0
   Connecting........... **RESET**
   Detecting chip type... Unsupported detection protocol, switching and trying again...
   Connecting....
   ...
   --- idf_monitor on /dev/ttyUSB0 115200 ---
   ...
   
##### BMP280
 
    cd ~/esp/ceiot_base/config
    cp config.h.template config.h
    # modificar en config.h la IP del servidor, las credenciales de WiFi y DEVICE_ID.
    cd ~/esp/ceiot_base/esp32-bmp280
    idf.py set-target esp32
    ../set-wifi.sh
    idf.py build
    idf.py flash
    idf.py monitor

##### DHT11
 
    cd ~/esp/ceiot_base/config
    cp config.h.template config.h
    # modificar en config.h la IP del servidor, las credenciales de WiFi y DEVICE_ID.
    cd ~/esp/ceiot_base/esp32
    idf.py set-target esp32
    ../set-wifi.sh
    idf.py build
    idf.py flash
    idf.py monitor

#### ESP32c3

##### BMP280
 
    cd ~/esp/ceiot_base/config
    cp config.h.template config.h
    # modificar en config.h la IP del servidor, las credenciales de WiFi y DEVICE_ID.
    cd ~/esp/ceiot_base/esp32c3-bmp280
    idf.py set-target esp32c3
    ../set-wifi.sh
    idf.py build
    idf.py flash
    idf.py monitor
    
#### ESP32s2

##### DHT11
 
    cd ~/esp/ceiot_base/config
    cp config.h.template config.h
    # modificar en config.h la IP del servidor, las credenciales de WiFi y DEVICE_ID.
    cd ~/esp/ceiot_base/esp32s2
    idf.py set-target esp32s2
    ../set-wifi.sh
    idf.py build
    idf.py flash
    idf.py monitor

## Paso 4: Fork del proyecto

### Generación SSH keys

     # En una terminal
     ssh-keygen -t ed25519 -C "your_email@example.com"
     # enter, enter, enter...
     # copiar al portapapeles el contenido de .ssh/id_ed25519.pub

     # En la interfaz web de github
     # Setting
     # SSH and GPG keys
     # New SSH key
     # Definir un título y pegar el contenido del portapapeles
     # Tomado de https://docs.github.com/articles/generating-an-ssh-key/
   
### Cambio url

     cd ~/esp/ceiot_base
     # en .git/config reemplazar
     # url = https://github.com/cpantel/ceiot_base.git
     # por
     # url = git@github.com:XXXXX/ceiot_base.git
     # siendo XXXXX tu usuario git

### Prueba (no hacer aún)

     # agregar al final de README.md "tocado por XXXXX"
     git status ; # para ver que archivos cambiaron
     git diff   ; # para ver los cambios
     git add README.md
     git commit -m "prueba"
     git push

## Anexo 1: Conexión del sensor

### ESP32 DHT11

![](./img/esp32_dht11-r.png)

![](./img/esp32_dht11.png)

### ESP32 BMP280

![](./img/esp32_bmp280.png)

### ESP32c3 DHT11

### ESP32c3 BMP280

![](./img/esp32c3_bmp280.png)

### ESP32s2 DHT11

### ESP32s2 BMP280

### ESP8266 DHT11

## Anexo 2: (opcional) Alias útiles para git

     git config --global alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit"
     git config --global alias.lola "log --graph --decorate --pretty=oneline --abbrev-commit --all"
     git config --global alias.lolg "log --graph --decorate --pretty=format:'%Cgreen %ci %Cblue %h %Cred %d %Creset %s'"

## Anexo 2: (opcional) Entorno ArduinoIDE

### ESP8266

#### DHT11

     # Descargar de https://www.arduino.cc/en/software
     cd ~/esp
     tar -xf ../Downloads/arduino-x.x.xx-linux64.tar.xz
     ./arduino-x.x.xx/arduino
     # File -> preferences -> Additional Boars Manager URLs
     # http://arduino.esp8266.com/stable/package_esp8266com_index.json
     # Tools -> Board -> Board Manager -> search esp8266 -> esp8266 by ESP8266 Community -> install
     # Tools -> Board ->ESP8266 Generic Module
     # Tools -> Manage Libraries -> search dht sensor -> DHT sensor library for ESPx -> install
     # Conectar device
     # Tools -> Port -> /dev/ttyUSB0
     # File -> Open -> ~/esp/ceiot_base/esp8266-arduino/PostHttpClient
     # modificar en ~/esp/ceiot_base/config/config.h la IP del servidor, las credenciales de WiFi y DEVICE_ID.
     # Sketch -> Upload

[Más detalles en el Plan B](https://seguridad-agile.blogspot.com/2022/03/ejemplo-de-esp8266-con-lectura-de-dht11planB.html)


### Entorno ESP8266_RTOS_SDK para ESP8266

Este entorno no me funcionó y además rompió el de ESP-IDF.

[Ejemplo de ESP8266 con lectura de DHT11](https://seguridad-agile.blogspot.com/2022/03/ejemplo-de-esp8266-con-lectura-de-dht11.html)

## TODO

Cambios a aplicar tras terminar los alumnos con el paso 3.

### Persistencia

Que el sistema implemente un endpoint que active guardar en un archivo lo que haya en las bases y al reiniciar que restaure. O implementar en tools mecanismos explícitos.

### Ubicación config.h

En los main.c hay una referencia a un archivo que no puede alcanzar por rutas relativas.

#include "/home/iot/esp/ceiot_base/config/config.h"   // esto es mejorable...

Lo mejor sería cambiarle el nombre a set-wifi.sh para que además copie config/config.h a la carpeta del dispositivo.

### Contenido config.h

Sería conveniente quitar de main.c cualquier elemento variable para no afectar el versionado. Habría que llevar a config.h DEVICE_ID, ONE_WIRE_GPIO, SDA_GPIO, SCL_GPIO :

### DHT11 explícito

Renombrar esp32 a esp32-dht11 
