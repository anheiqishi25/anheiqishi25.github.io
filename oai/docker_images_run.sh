#!/bin/bash
# https://github.com/OPENAIRINTERFACE/openair-epc-fed/blob/master/docs/CONFIGURE_CONTAINERS.md

echo "################################################################################"
echo "# IP FORWARD"
echo "################################################################################"
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT
# On your EPC Docker Host: recover the MME IP address:
docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-mme
# Return MME IP address: 192.168.61.3
# SPGW-U IP address 192.168.61.5

echo "################################################################################"
echo "# Config Cassandra"
echo "################################################################################"
docker cp component/oai-hss/src/hss_rel14/db/oai_db.cql prod-cassandra:/home
docker exec -it prod-cassandra /bin/bash -c "nodetool status"
Cassandra_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-cassandra`
docker exec -it prod-cassandra /bin/bash -c "cqlsh --file /home/oai_db.cql ${Cassandra_IP}"

echo "################################################################################"
# Config HSS
echo "################################################################################"
HSS_IP=`docker exec -it prod-oai-hss /bin/bash -c "ifconfig eth1 | grep inet" | sed -f ./ci-scripts/convertIpAddrFromIfconfig.sed`
python3 component/oai-hss/ci-scripts/generateConfigFiles.py --kind=HSS --cassandra=${Cassandra_IP} --hss_s6a=${HSS_IP} --apn1=apn1.carrier.com --apn2=apn2.carrier.com --users=200 --imsi=320230100000001 --ltek=0c0a34601d4f07677303652c0462535b --op=63bfa50ee6523365ff14c1f45f88737d --nb_mmes=1 --from_docker_file
docker cp ./hss-cfg.sh prod-oai-hss:/openair-hss/scripts
docker exec -it prod-oai-hss /bin/bash -c "cd /openair-hss/scripts && chmod 777 hss-cfg.sh && ./hss-cfg.sh"

echo "################################################################################"
echo "# Config MME"
echo "################################################################################"
MME_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-mme`
SPGW0_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-spgwc`
python3 component/oai-mme/ci-scripts/generateConfigFiles.py --kind=MME --hss_s6a=${HSS_IP} --mme_s6a=${MME_IP} --mme_s1c_IP=${MME_IP} --mme_s1c_name=eth0 --mme_s10_IP=${MME_IP} --mme_s10_name=eth0 --mme_s11_IP=${MME_IP} --mme_s11_name=eth0 --spgwc0_s11_IP=${SPGW0_IP} --mcc=320 --mnc=230 --tac_list="5 6 7" --from_docker_file
docker cp ./mme-cfg.sh prod-oai-mme:/openair-mme/scripts
docker exec -it prod-oai-mme /bin/bash -c "cd /openair-mme/scripts && chmod 777 mme-cfg.sh && ./mme-cfg.sh"

echo "################################################################################"
echo "# Config SPGW-C"
echo "################################################################################"
python3 component/oai-spgwc/ci-scripts/generateConfigFiles.py --kind=SPGW-C --s11c=eth0 --sxc=eth0 --apn=apn1.carrier.com --dns1_ip=YOUR_DNS_IP_ADDRESS --dns2_ip=A_SECONDARY_DNS_IP_ADDRESS --from_docker_file
docker cp ./spgwc-cfg.sh prod-oai-spgwc:/openair-spgwc
docker exec -it prod-oai-spgwc /bin/bash -c "cd /openair-spgwc && chmod 777 spgwc-cfg.sh && ./spgwc-cfg.sh"
ifconfig lo:s5c 127.0.0.15 up
ifconfig lo:p5c 127.0.0.16 up

echo "################################################################################"
echo "# Config SPGW-U"
echo "################################################################################"
python3 component/oai-spgwu-tiny/ci-scripts/generateConfigFiles.py --kind=SPGW-U --sxc_ip_addr=${SPGW0_IP} --sxu=eth0 --s1u=eth0 --from_docker_file
docker cp ./spgwu-cfg.sh prod-oai-spgwu-tiny:/openair-spgwu-tiny
docker exec -it prod-oai-spgwu-tiny /bin/bash -c "cd /openair-spgwu-tiny && chmod 777 spgwu-cfg.sh && ./spgwu-cfg.sh"



