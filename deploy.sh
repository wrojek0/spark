#!/bin/bash

#Skrypt powinien byc odpalany na maszynie MASTER, uruchamia kontenery na wyspecyfikowanych maszynach.
#Aby skrypt dzialal poprawnie nalezy upewnic sie ze odpowiednie klucze z maszyny master sa na maszynach docelowych, aby ssh bylo mozliwe bez hasla. 
#ssh-copy-id user@remote_host


# Zmienne środowiskowe
WORKER_IPS=("10.0.0.2" "10.0.0.3")
WORKER_USERS=("slave1" "slave2")


#Moze to byc id obrazu, ktory juz zostal pobrany z repozytorium docker'a lub podac bezposrednio target w repozytorium np: username/image_id:version
CONTAINER_IMAGE="wrojek0/spark-image:5.0"

#Uprzednio konieczne dodanie usera do grupy docker, aby moc wolac komendy dockerowe bez "sudo"
#Przyklad: sudo gpasswd -a $USER docker


# Przy pomocy flagi -v mozna rowniez podmontowac lokalne foldery do kontenera np: -v /source/input:/destination/
echo "[DEPLOY.sh] Uruchamianie kontenera na maszynie master..."

# Przy pomocy flagi -v mozna rowniez podmontowac lokalne foldery do kontenera np: -v /source/input:/destination/
docker run -d --expose=8888 -p 8889:8889 -p 8080:8080 -p 7077:7077 -p 8888:8888 --network host -v ~/Pulpit/wrojek:/app/data $CONTAINER_IMAGE master


echo "[DEPLOY.sh] Uruchamianie workerow..." 
for i in "${!WORKER_IPS[@]}"; do
    WORKER_IP=${WORKER_IPS[$i]}
    WORKER_USER=${WORKER_USERS[$i]}
    
    echo "[DEPLOY.SH] Uruchamianie kontenera na maszynie worker ($WORKER_IP)..."
    ssh $WORKER_USER@$WORKER_IP "docker run -d --expose=8888 -p 8889:8889 -p 8080:8080 -p 7077:7077 -p 8888:8888 --network host $CONTAINER_IMAGE worker"

done

echo "[DEPLOY.sh] Kontenery zostały uruchomione na wszystkich maszynach."
