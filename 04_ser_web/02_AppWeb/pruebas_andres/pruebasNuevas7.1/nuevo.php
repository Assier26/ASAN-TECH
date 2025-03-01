<?php
include('conexion.php');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nombre = $_POST['nombre_producto'];
    $descripcion = $_POST['descripcion'];
    $precio = $_POST['precio'];
    $cantidad = $_POST['cantidad'];

    $sql = "INSERT INTO productos (nombre_producto, descripcion, precio, cantidad) VALUES ('$nombre', '$descripcion', '$precio', '$cantidad')";

    if ($conexion->query($sql) === TRUE) {
        header("Location: cpanel.php");
    } else {
        print "Error al añadir producto: " . $conexion->error;
    }
}
?>

<form method="POST" action="">
    Nombre: <input type="text" name="nombre_producto" required><br>
    Descripción: <input type="text" name="descripcion" required><br>
    Precio: <input type="number" name="precio" required><br>
    Cantidad: <input type="number" name="cantidad" required><br>
    <input type="submit" value="Añadir Producto">
</form>
