#!/bin/bash
# Script sauvegarde BDD + horodatage (jour-mois-annee-Heure-Minute)
#	fichier de log /var/log/saveBDD.log

#Variables#####################################################################
NOW=$(date +"%d-%m-%Y-%H"H"-%M"m"")
LISTEBDD=$( echo 'show databases' | mysql -u$LOGIN -p$PWD)
BACKUP_REP=$(echo "/backup")
LOGIN=$(echo "root")
PWD=$(echo "rootroot")
TIME=$(echo "30")

################################################################################

#Si le dossier /backup n'existe pas, le créer###################################
#Creation de permissions acces total
if [ ! -d "$BACKUP_REP" ];then
echo "Création du dossier sauvegardes !";
mkdir $BACKUP_REP
chmod 777 -R $BACKUP_REP
fi
################################################################################

#Créer un dossier pour chaque BDD, sauvegarder le base sql,#####################
#Compression du fichier sql en tar.gz, suppression du fichier sql d'origine
for bdd in "$LISTEBDD"; do
	mkdir "$BACKUP_REP"/"$bdd"/
	mysqldump -u$LOGIN -p$PWD $bdd > /backup/"$bdd"/"$bdd"_"$NOW".sql
	tar zcvf $BACKUP_REP/"$bdd"/"$bdd"_"$NOW".sql.tar.gz /backup/"$bdd"/"$bdd"_"$NOW".sql
	rm $BACKUP_REP/"$bdd"/"$bdd"_"$NOW".sql
done
################################################################################

#Recherche les répertoires de sauvegardes#######################################
#Supprime les répertoires créés il y à plus de 30 jours
find $BACKUP_REP/ -mtime +$TIME -exec rm {} \;
echo "Backup OK"
################################################################################

#Creation du fichier de log des databases sauvegardées##########################
cd /var/log/
if [ ! "saveBDD.log" ];then
echo "Création du fichier de log";
touch saveBDD.log
fi

#Ecriture dans le fichier de log
echo "$NOW" >> /var/log/saveBDD.log
echo "$LISTEBDD" >> /var/log/saveBDD.log
echo "---------" >> /var/log/saveBDD.log
echo "" >> /var/log/saveBDD.log
################################################################################
