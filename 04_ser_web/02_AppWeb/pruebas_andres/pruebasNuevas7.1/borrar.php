<?php
include('conexion.php');

$id_producto = $_GET['id_producto'];
$sql = "DELETE FROM productos WHERE id_producto ='$id_producto'";
$conexion->query($sql);
header("Location: cpanel.php");



?>

