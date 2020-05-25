https://neo4j.com/developer/kb/how-to-setup-neo4j-to-startup-on-linux-server-reboot/
start Neo4J: service neo4j start
Gephi: ./home/lnr-ai/gephi-0.9.2/bin/gephi
sudo systemctl status neo4j
sudo systemctl start neo4j
sudo systemctl stop neo4j

journalctl -e -u neo4j
sudo chown -R neo4j:adm movie.db/


<neo4j-home> = ./var/lib/neo4j/



sudo find . -name "neo4j"
./var/lib/neo4j/import
./var/lib/neo4j/data/dbms/auth

sudo rm -rf  ./var/lib/neo4j/data/dbms/auth
    ./usr/share/neo4j
    ./usr/share/neo4j/bin/neo4j
    ./usr/share/doc/neo4j
    ./usr/share/lintian/overrides/neo4j
    ./usr/bin/neo4j
    ./media/lnr-ai/neo4j
    ./var/lib/neo4j
    ./var/log/neo4j
    ./etc/neo4j
    ./etc/default/neo4j
    ./etc/init.d/neo4j


nano /etc/neo4j/neo4j.conf
dbms.directories.data=/var/lib/neo4j/data
dbms.directories.plugins=/var/lib/neo4j/plugins
dbms.directories.certificates=/var/lib/neo4j/certificates
dbms.directories.logs=/var/log/neo4j
dbms.directories.lib=/usr/share/neo4j/lib
dbms.directories.run=/var/run/neo4j


<!-- /usr/bin/neo4j-admin dump --database=graph.db --to=/media/lnr-ai/neo4j/backups/2016-10-02.dump -->
sudo /usr/bin/neo4j-admin dump --database=graph.db --to=/media/lnr-ai/neo4j/backups/2016-10-02.dump


<!-- 
https://neo4j.com/developer/kb/how-to-setup-neo4j-to-startup-on-linux-server-reboot/

To setup the automation of stop/start of Neo4j when the Linux server is rebooted, follow these steps:
As root: -->
<!-- 
a) Create the file /etc/init.d/neo4j_ctl with the following contents:

#!/bin/sh

        OWNER=neo4j #Set to the owner of the Neo4j installation

        case "$1" in
        'start')
            su - $OWNER -c "service neo4j start"
            ;;
        'stop')
            su - $OWNER -c "service neo4j stop"
            ;;
        'restart')
            su - $OWNER -c "service neo4j restart"
            ;;
        *)
            echo "Usage: $0 { start | stop | restart }"
            exit 1
            ;;
        esac
        exit 0 -->

<!-- 
eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJjYWxsYmFjayI6IiIsImVtYWlsIjoiY2hyaXN0b3N0ckBuZWRiYW5rLmNvLnphIiwiZm9ybWF0IjoianNvbiIsIm9yZyI6Ik5FREJBTksgR1JPVVAgTFREIiwicHViIjoibmVvNGouY29tIiwicmVnIjoiQ2hyaXN0byBTdHJ5ZG9tIiwic3ViIjoibmVvNGotZGVza3RvcCIsImV4cCI6MTYxODY3Mzc5NSwidmVyIjoiKiIsImlzcyI6Im5lbzRqLmNvbSIsIm5iZiI6MTU4NzEzNzc5NSwiaWF0IjoxNTg3MTM3Nzk1LCJqdGkiOiJSNTE0eHBNU1IifQ.GjJzUhkkTcLi0OlF_uBNp4hqAPeQbz2LU2-mh6-3xxL88qEhqNQVF1sUTa6lM8kk974oC9qlwuEHx6jtVRq0rEhDOAA3x12M9DEQGUfICHC1-ef5lA06iiqYJXo1pQPXjDYQiHY1EwL4nvLvrZdz2SjBw-aP2QychCYZeE8ehcjcvChqEZwNxRoZPx4_eTx9JmSHJG9pCmDZ5x1wH3vx5EI3wKz7Qo1y2hBtK8RWIZzL0AYyQmg7UYVA7k1i_RedJlyiogL38yYSXMBUZ_RWOGS6g4eDHbzY9urlIu6SAP3QBHeUske4XiBAKTmsuwLUR1Xi5Rg5nyhxqgfVTl5Qag -->


#=========================================================================================================
https://neo4j.com/graphacademy/online-training/neo4j-administration/part-3/:
https://neo4j.com/docs/operations-manual/3.5/configuration/file-locations/
Managing a Neo4j Database:

The status command gives you a short glimpse of the status of the Neo4j instance. In some cases, although the instance is active, it may not have started successfully. You may want to examine more information about the instance, such as the folders it is using at runtime and information about activity against the instance, and especially if any errors occurred during startup. As an administrator, you should become familiar with the types of records that are written to the log files for the Neo4j instance.

journalctl -u neo4j


; run the follwoing cypher script from  file:
/usr/bin/cypher-shell -u neo4j -p neo4j < /media/lnr-ai/downloads/movieDB.cypher
/var/lib/neo4j/data
/var/lib/neo4j/data/databases/graph.db
neo4j-admin dump --database=graph.db --to=/media/lnr-ai/neo4j/dump/ne04j_dump_file.db
sudo neo4j-admin load --from=/media/lnr-ai/neo4j/dump/ne04j_dump_file.db --database=movie.db [--force=true]



Purpose of folder	Description
Tools

The /usr/bin folder contains the tooling scripts you will typically run to manage the Neo4j instance.

Configuration

Neo4j.conf is the primary configuration file for the Neo4j instance and resides in the /etc/neo4j folder.

Logging

The /var/log/neo4j folder contains log files that you can monitor.

Database(s)

The /var/lib/neo4j/data folder contains the database(s).

#-------------------------------------------------------------------------------------------------------

mkdir /usr/local/work

sudo /usr/bin/neo4j-admin dump --database=graph.db --to=/usr/local/work/movie-dump

# Exercise #4: Modifying the location of the database --------------------------------------------------
sudo systemctl stop neo4j
cd /usr/local/data
sudo chown -R neo4j:neo4j data

; change neo4j.conf:
dbms.directories.data=/usr/local/data #/var/lib/neo4j/data
sudo systemctl start neo4j
journalctl -e -u neo4j

sudo /usr/bin/neo4j-admin load --database=movie3.db --from=/usr/local/work/movie-dump

sudo chown -R neo4j:neo4j data
journalctl -e -u neo4j
sudo systemctl status neo4j
/usr/bin/cypher-shell -u neo4j -p newPassword

neo4j-admin check-consistency --database=movie3.db --report-dir=/usr/local/reports --verbose=true

sudo /usr/bin/neo4j-admin load --database=movie3-copy.db --from=/usr/local/work/movie-dump

sudo chown -R neo4j:neo4j data
neo4j-admin check-consistency --database=movie4.db --report-dir=/usr/local/reports --verbose=true
vi /usr/local/data/databases/movie3-copy.db/neostore.nodestore.db

#Exercise #6: Scripting changes to the database

sudo rm -rf /usr/local/data/databases/movie3-copy.db
/usr/bin/cypher-shell -u neo4j -p newPassword

sudo vi /usr/local/work/AddConstraints.cypher 
chmod +x /usr/local/work/AddConstraints.cypher

sudo vi /usr/local/work/AddConstraints.sh
sudo chmod +x /usr/local/work/AddConstraints.sh

cat /usr/local/work/AddConstraints.cypher | /usr/bin/cypher-shell -u neo4j -p newPassword --format verbose
#
sudo vi /usr/local/work/MaintainDB.sh
sudo chmod +x /usr/local/work/MaintainDB.sh
rm -rf /usr/local/work/MaintainDB.log
/usr/local/work/AddConstraints.sh 2>&1 >> /usr/local/work/MaintainDB.log
/usr/local/work/MaintainDB.log

./usr/local/work/MaintainDB.sh

/usr/bin/cypher-shell -u neo4j -p newPassword
CALL db.constraints();

sudo chown -R neo4j:neo4j work

# ---------------------------------------------------------------------------------------------------------
; https://github.com/neo4j-contrib/neo4j-graph-algorithms/releases
cp /media/lnr-ai/christo/neo4j/plugins
sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins

sudo chmod +x /var/lib/neo4j/plugins/
vi listProcedures.sh
echo "CALL dbms.procedures() YIELD name;" | /usr/bin/cypher-shell -u neo4j -p training-helps --format plain > /usr/local/work/Procedures.txt
sudo chown -R neo4j:neo4j /usr/local/work/listProcedures.sh
sudo chmod +x /usr/local/work/listProcedures.sh

cp /media/lnr-ai/christo/neo4j/plugins


sudo mkdir /usr/local/backup
sudo chown -R neo4j:neo4j /usr/local/backup

sudo neo4j-admin backup --backup-dir=/usr/local/backup --name=movie300-backup --from=localhost:6362 --check-consistency=true --cc-report-dir=/usr/local/work/reports


sudo vi /usr/local/data/databases/movie3.db/neostore.nodestore.db
sudo neo4j-admin check-consistency --database=movie3.db --report-dir=/usr/local/reports --verbose=true

sudo neo4j-admin restore --from=/usr/local/backup/movie300-backup --database=movie3 --force=true
sudo neo4j-admin check-consistency --database=movie3.db --report-dir=/usr/local/reports --verbose=true


#---------------------------------------------------------------------------------------------------
neo4j-admin import  --database crimes.db --nodes crimes_header.csv,crimes.csv --nodes beats.csv --nodes primaryTypes.csv --relationships crimesBeats.csv --relationships:PRIMARY_TYPE crimesPrimaryTypes.csv --report-file /usr/local/reports/
sudo chown -R neo4j:neo4j crimes.db
--nodes crimes_header.csv,crimes.csv
--nodes beats.csv
--nodes primaryTypes.csv
--relationships crimesBeats.csv
--relationships:PRIMARY_TYPE crimesPrimaryTypes.csv

/var/lib/neo4j/import
sudo cp /media/lnr-ai/downloads/crimes.csv /var/lib/neo4j/import/
sudo cp /media/lnr-ai/downloads/crimes_header.csv /var/lib/neo4j/import/
sudo cp /media/lnr-ai/downloads/beats.csv /var/lib/neo4j/import/
sudo cp /media/lnr-ai/downloads/primaryTypes.csv /var/lib/neo4j/import/
sudo cp /media/lnr-ai/downloads/crimesBeats.csv /var/lib/neo4j/import/
sudo cp /media/lnr-ai/downloads/crimesPrimaryTypes.csv /var/lib/neo4j/import/

sudo neo4j-admin check-consistency --database=crimes.db --report-dir=/usr/local/reports --verbose=true

sudo /usr/bin/cypher-shell -u neo4j -p newPassword

sudo cp /media/lnr-ai/downloads/crimes.csv /var/lib/neo4j/import/