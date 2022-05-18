SSID=$( grep "^#define WIFI_SSID"  ../config/config.h | rev | cut -d'"' -f 2 | rev )
PASSWORD=$( grep "^#define WIFI_PASSWORD"  ../config/config.h | rev | cut -d'"' -f 2 | rev )

sed sdkconfig -i -e 's/CONFIG_EXAMPLE_WIFI_SSID=".*/CONFIG_EXAMPLE_WIFI_SSID="Fibertel WiFi153 2.4GHz"/'
#sed sdkconfig -i -e 's/CONFIG_EXAMPLE_WIFI_SSID=".*/CONFIG_EXAMPLE_WIFI_SSID="'${SSID}'"/'
sed sdkconfig -i -e 's/CONFIG_EXAMPLE_WIFI_PASSWORD=".*/CONFIG_EXAMPLE_WIFI_PASSWORD="34250596356318"/'
#sed sdkconfig -i -e 's/CONFIG_EXAMPLE_WIFI_PASSWORD=".*/CONFIG_EXAMPLE_WIFI_PASSWORD="'${PASSWORD}'"/'
