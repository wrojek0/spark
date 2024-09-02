#!/bin/bash

# Funkcja wyświetlająca pomoc
function show_help() {
    echo "Użycie: $0 [-l] [-i INTERFACE -a IP_ADDRESS -m NETMASK -g GATEWAY [-d DNS1[,DNS2]]]"
    echo
    echo "Opcje:"
    echo "  -l             Wyświetl listę interfejsów sieciowych i zakończ"
    echo "  -i INTERFACE   Nazwa interfejsu sieciowego (np. eth0)"
    echo "  -a IP_ADDRESS  Adres IP do przypisania"
    echo "  -m NETMASK     Maska podsieci (np. 255.255.255.0)"
    echo "  -g GATEWAY     Brama domyślna"
    echo "  -d DNS         Adresy DNS (oddzielone przecinkami) - opcjonalne"
    echo "  -h             Wyświetl tę pomoc"
    exit 1
}

# Flaga do wyświetlania interfejsów
LIST_INTERFACES=0

# Parsowanie argumentów
while getopts ":li:a:m:g:d:h" opt; do
  case $opt in
    l) LIST_INTERFACES=1
    ;;
    i) INTERFACE="$OPTARG"
    ;;
    a) IP_ADDRESS="$OPTARG"
    ;;
    m) NETMASK="$OPTARG"
    ;;
    g) GATEWAY="$OPTARG"
    ;;
    d) IFS=',' read -r DNS1 DNS2 <<< "$OPTARG"
    ;;
    h) show_help
    ;;
    \?) echo "Nieznana opcja -$OPTARG" >&2; show_help
    ;;
    :) echo "Opcja -$OPTARG wymaga argumentu." >&2; show_help
    ;;
  esac
done

# Jeżeli flaga -l została użyta, wyświetl interfejsy i zakończ
if [ $LIST_INTERFACES -eq 1 ]; then
    echo "Dostępne interfejsy sieciowe:"
    ip link show | awk -F: '$1 !~ "lo|vir|wl|br|^[^0-9]"{print $2}'
    exit 0
fi

# Sprawdzenie, czy wszystkie wymagane argumenty są podane
if [ -z "$INTERFACE" ] || [ -z "$IP_ADDRESS" ] || [ -z "$NETMASK" ] || [ -z "$GATEWAY" ]; then
    echo "Brakuje jednego z wymaganych argumentów." >&2
    show_help
fi

# Wyłączanie interfejsu
echo "Wyłączam interfejs $INTERFACE..."
sudo ifconfig $INTERFACE down

# Konfigurowanie adresu IP i maski podsieci
echo "Konfiguruję interfejs $INTERFACE z adresem IP $IP_ADDRESS..."
sudo ifconfig $INTERFACE $IP_ADDRESS netmask $NETMASK

# Włączanie interfejsu
echo "Włączam interfejs $INTERFACE..."
sudo ifconfig $INTERFACE up

# Ustawianie bramy domyślnej przy użyciu iptables
echo "Ustawiam bramę domyślną na $GATEWAY..."
sudo iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
sudo iptables -A FORWARD -i $INTERFACE -j ACCEPT
sudo ip route add default via $GATEWAY

# Konfigurowanie DNS (jeśli podane)
if [ -n "$DNS1" ]; then
    echo "Konfiguruję DNS..."
    sudo bash -c "echo 'nameserver $DNS1' > /etc/resolv.conf"
    if [ -n "$DNS2" ]; then
        sudo bash -c "echo 'nameserver $DNS2' >> /etc/resolv.conf"
    fi
fi

echo "Konfiguracja zakończona pomyślnie."
