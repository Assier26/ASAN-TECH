<?php
$servidor = "localhost";
$usuario = "root";
$password = "";
$base_de_datos = "asan_tech";

$conexion = new mysqli($servidor, $usuario, $password, $base_de_datos);

if ($conexion->connect_error) {
    die("Conexión fallida: " . $conexion->connect_error);
}
?>
