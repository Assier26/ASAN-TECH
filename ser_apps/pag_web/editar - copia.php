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
    <input type="submit" value="Añadir Producto">
</form>
<?php }?>