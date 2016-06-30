# pasalabase
script para hacer una migración de una bd del cms drupal 7 de un servidor de test a producción, evitando las tablas de caché y usuarios

#Ejecución

- Crear la tabla bandera en el entorno stage, el script se encuentra en la carpeta sql/bandera.sql
- Darle permisos de ejecución al archivo pasalabase.sh
- En la variable "rutadb" darle la ruta en donde se van a guardar los .sql
