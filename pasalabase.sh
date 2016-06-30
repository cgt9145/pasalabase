#!/bin/bash

# -*- ENCODING: UTF-8 -*-

##Definir parametros de conexión
sql_host='' #Host de la base de datos producción
sql_hostT='' #Host de la base de datos stage
sql_usuario='' #usuario de la base de datos
sql_usuarioT='' #usuario de la base de datos stage
sql_password='' #contraseña de la base de datos
sql_passwordT='' #contraseña de la base de datos stage
sql_databasetest='' #nombre de la base de datos entorno stage
sql_databaseprod="" #nombre de la base de datos entorno producción
#Sie el modifica #

#Se pone ruta para almacenar los dump
rutadb=""

##Parametros de conexión a mysql para la base de test
sql_argstest="-h $sql_hostT -u $sql_usuarioT -p$sql_passwordT -D $sql_databasetest -s -e"
sql_argstestDump="-h $sql_hostT -u $sql_usuarioT -p$sql_passwordT"

###Revisa la tabla bandera y trae el valor
revisaBandera=$(mysql $sql_argstest "SELECT bandera FROM bandera WHERE id=1")

###Hace la validación si la bandera se encuentra en "S" y ejecuta la actualización

if [ "$revisaBandera" != 'N' ]; then

	
	##Parametros de conexión a mysql para la base de produccion
	sql_argsprod="-h $sql_host -u $sql_usuario -p$sql_password -D $sql_databaseprod -s -e"
	sql_argsprodDump="-h $sql_host -u $sql_usuario -p$sql_password"

	##Sentencia sql encontrar las bases cache
	buscacache=$(mysql $sql_argstest "SELECT CONCAT(GROUP_CONCAT(table_name))  AS statement FROM information_schema.tables  WHERE table_name LIKE 'cache%';")

	buscacacheProd=$(mysql $sql_argsprod "SELECT CONCAT(GROUP_CONCAT(table_name))  AS statement FROM information_schema.tables  WHERE table_name LIKE 'cache%';")

	line=$buscacache
	linePro=$buscacacheProd
	#echo $line

	#Crea un arreglo con los datos traidos en $line
	OIFS=$IFS
	IFS=","
	cacheArray=($line)
	#Recorre el arreglo y trunca las tablas
	for ((i=0; i<${#cacheArray[@]}; ++i))
	 do
	 	echo "tablaTest $i: ${cacheArray[$i]}"
	 	truncatabla=$(mysql -u $sql_usuarioT -p$sql_passwordT -D $sql_databasetest -s -e "TRUNCATE TABLE ${cacheArray[$i]};")
	 done


	########################## Se pasa a produccion
	IFS=$OIFS

	OIFS=$IFS
	IFS=","
	cacheArrayP=($linePro)
	#Recorre el arreglo y trunca las tablas
	for ((i=0; i<${#cacheArrayP[@]}; ++i))
	 do
	 	echo "tablaProd $i: ${cacheArrayP[$i]}"
	 	truncatabla=$(mysql -h $sql_host -u $sql_usuario -p$sql_password -D $sql_databaseprod -s -e "TRUNCATE TABLE ${cacheArrayP[$i]};")
	 done

	IFS=$OIFS



	#Saca el primer backup de la base de test sin caché
	echo 'Hola saco un dump de test'
	sacadumptest=$(mysqldump $sql_argstestDump $sql_databasetest > $rutadb/testdb.sql) #Nombre dump archivo base test
 	echo 'Hola saco un dump de producción'
	sacadumpprod=$(mysqldump $sql_argsprodDump $sql_databaseprod > $rutadb/proddb.sql) #Nombre dump archivo base producción



	##Saca dump de las tablas de test ignorando las tablas cache y usuarios, si tiene campos creados agregar, las tablas referentes a los campos creados ejemplo "--ignore-table=$sql_databasetest.field_data_field_sexo_user \"
	echo 'Hola saco un dump ignorando cache y usuarios'
	ignoracacheTest=$(mysqldump $sql_argstestDump $sql_databasetest --ignore-table=$sql_databasetest.cache \
	--ignore-table=$sql_databasetest.cache_admin_menu \
	--ignore-table=$sql_databasetest.cache_block \
	--ignore-table=$sql_databasetest.cache_bootstrap \
	--ignore-table=$sql_databasetest.cache_feeds_http \
	--ignore-table=$sql_databasetest.cache_field \
	--ignore-table=$sql_databasetest.cache_filter \
	--ignore-table=$sql_databasetest.cache_form \
	--ignore-table=$sql_databasetest.cache_image \
	--ignore-table=$sql_databasetest.cache_libraries \
	--ignore-table=$sql_databasetest.cache_menu \
	--ignore-table=$sql_databasetest.cache_metatag \
	--ignore-table=$sql_databasetest.cache_page \
	--ignore-table=$sql_databasetest.cache_path \
	--ignore-table=$sql_databasetest.cache_rules \
	--ignore-table=$sql_databasetest.cache_token \
	--ignore-table=$sql_databasetest.cache_update \
	--ignore-table=$sql_databasetest.cache_views \
	--ignore-table=$sql_databasetest.cache_views_data \
	--ignore-table=$sql_databasetest.cache \
	--ignore-table=$sql_databasetest.cache_admin_menu \
	--ignore-table=$sql_databasetest.cache_block \
	--ignore-table=$sql_databasetest.cache_bootstrap \
	--ignore-table=$sql_databasetest.cache_feeds_http \
	--ignore-table=$sql_databasetest.cache_field \
	--ignore-table=$sql_databasetest.cache_filter \
	--ignore-table=$sql_databasetest.cache_form \
	--ignore-table=$sql_databasetest.cache_image \
	--ignore-table=$sql_databasetest.cache_libraries \
	--ignore-table=$sql_databasetest.cache_menu \
	--ignore-table=$sql_databasetest.cache_metatag \
	--ignore-table=$sql_databasetest.cache_page \
	--ignore-table=$sql_databasetest.cache_path \
	--ignore-table=$sql_databasetest.cache_rules \
	--ignore-table=$sql_databasetest.cache_token \
	--ignore-table=$sql_databasetest.cache_update \
	--ignore-table=$sql_databasetest.cache_views \
	--ignore-table=$sql_databasetest.cache_views_data \
	--ignore-table=$sql_databasetest.hybridauth_identity \
	--ignore-table=$sql_databasetest.hybridauth_session \
	--ignore-table=$sql_databasetest.users \
	--ignore-table=$sql_databasetest.bandera \
	--ignore-table=$sql_databasetest.users_roles > $rutadb/migrar.sql)

	##Importar dump de test a produccion sin cache ni usuarios
	echo 'Hola importo el dump'
	importaMigrado=$(mysql $sql_argstestDump $sql_databaseprod < $rutadb/migrar.sql)

	##Bajo la bandera para que no actualice siempre
	echo 'Hola, bajo la bandera'
	revisaBandera=$(mysql $sql_argstest "UPDATE bandera SET bandera='N' WHERE id=1")
else
	##Cuando la bandera se encuentra en 'N'
	echo 'No hay actualización'
	echo $revisaBandera
fi