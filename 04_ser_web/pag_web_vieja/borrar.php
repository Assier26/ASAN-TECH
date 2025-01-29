<?php
include('conexion.php');

$id=$_GET["id"];
$sql = "DELETE FROM productos WHERE id = $id";
$resultado = $conexion->query($sql);

header("Location: cpanel.php");
?>