#!/bin/bash


#Skrypt uruchamiany podczas inicjalizacji kontenera. Przyjmuje parametr master lub worker w zaleznosci w jakim trybie chcemy uruchomic serwer sparka

#unzip network-malware-detection-connection-analysis.zip

if [ "$1" = "master" ]; then
    export SPARK_HOME=/opt/bitnami/spark
    export PYSPARK_PYTHON=python3
    export PYSPARK_DRIVER_PYTHON=jupyter
    export PATH=$SPARK_HOME/bin:$PATH
    export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
    export PYTHONPATH=$SPARK_HOME/python/lib/py4j-0.10.9-src.zip:$PYTHONPATH
   
    $SPARK_HOME/sbin/start-master.sh --host 10.0.0.1

    
    jupyter notebook --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='spark-notebook'
elif [ "$1" = "worker" ]; then
    $SPARK_HOME/sbin/start-worker.sh spark://10.0.0.1:7077 -c 4 -m 4G
else
    echo "Unknown argument: $1"
    exit 1
fi


tail -f /dev/null



