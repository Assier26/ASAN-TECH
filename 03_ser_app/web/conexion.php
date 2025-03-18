<?php
$servidor = "192.168.1.13:30008";
$usuario = "admin";
$contrasena = "mi-contrasenia";
$base_de_datos = "mi_db";

$conexion = new mysqli($servidor, $usuario, $contrasena, $base_de_datos);

if ($conexion->connect_error) {
    die("Conexión fallida: " . $conexion->connect_error);
}
?>
