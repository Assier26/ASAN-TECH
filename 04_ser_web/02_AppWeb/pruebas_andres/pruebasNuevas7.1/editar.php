<?php
include('conexion.php');

$id_producto = $_GET['id_producto'];
$sql = "SELECT * FROM productos WHERE id_producto = $id_producto";
$resultado = $conexion->query($sql);
?>

<?php while ($fila = $resultado->fetch_assoc()) { ?>
       <form method="POST" action="">
            Nombre: <input type="text" name="nombre_producto" value="<?php print $fila['nombre_producto']; ?>" required><br>
            Descripción: <input type="text" name="descripcion" value="<?php print $fila['descripcion']; ?>" required><br>
            Precio: <input type="number" name="precio" value="<?php print $fila['precio']; ?>" required><br>
            Cantidad: <input type="number" name="cantidad" value="<?php print $fila['cantidad']; ?>" required><br>
            <input type="submit" value="Actualizar">
        </form>
<?php } ?>

<?php

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nombre_producto = $_POST['nombre_producto'];
    $descripcion = $_POST['descripcion'];
    $precio = $_POST['precio'];
    $cantidad = $_POST['cantidad'];

    $sql = "UPDATE productos SET nombre_producto='$nombre_producto', descripcion='$descripcion', precio='$precio', cantidad='$cantidad'
        WHERE id_producto=$id_producto";


    if ($conexion->query($sql) === TRUE) {
        header("Location: cpanel.php");
    } else {
        print "Error al editar producto: " . $conexion->error;
    }
}
?>

