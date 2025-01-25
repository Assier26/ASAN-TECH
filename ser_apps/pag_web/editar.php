<?php
include('conexion.php');

$id=$_GET["id"];
$sql = "SELECT * FROM productos WHERE id = $id";
$resultado = $conexion->query($sql);

?>
<?php while ($fila = $resultado->fetch_assoc()) { ?>
<form method="POST" action="">
    Nombre: <input type="text" name="nombre" value="<?php print $fila['nombre']; ?>" required><br>
    Descripción: <input type="text" name="descripcion" value="<?php print $fila['descripcion']; ?>" required><br>
    Precio: <input type="number" name="precio" value="<?php print $fila['precio']; ?>" required><br>
    Cantidad: <input type="number" name="cantidad" value="<?php print $fila['cantidad']; ?>" required><br>
    <input type="submit" value="Actualizar producto">
</form>
<?php }?>
<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nombre = $_POST['nombre'];
    $descripcion = $_POST['descripcion'];
    $precio = $_POST['precio'];
    $cantidad = $_POST['cantidad'];

    $sql = "UPDATE productos 
            SET nombre='$nombre' ,descripcion='$descripcion' ,precio=$precio ,cantidad=$cantidad
            WHERE id=$id";

    if ($conexion->query($sql) === TRUE) {
        header("Location: cpanel.php");
    } else {
        print "Error al añadir producto: " . $conexion->error;
    }
}
?>