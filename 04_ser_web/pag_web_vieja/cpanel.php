<?php
session_start();
if (!isset($_SESSION['nombre'])) {
    header("Location: login.php");
}

include('conexion.php');


// Mostrar los datos
$sql = "SELECT * FROM productos";
$resultado = $conexion->query($sql);
?>

<h1>Panel de Control</h1>
<a href="logout.php">Cerrar sesión</a>
<table border="1">
    <tr>
        <th>ID</th>
        <th>Nombre</th>
        <th>Descripción</th>
        <th>Precio</th>
        <th>Cantidad</th>
        <th>Acciones</th>
    </tr>
    <?php while ($fila = $resultado->fetch_assoc()) { ?>
        <tr>
            <td><?php print $fila['id']; ?></td>
            <td><?php print $fila['nombre']; ?></td>
            <td><?php print $fila['descripcion']; ?></td>
            <td><?php print $fila['precio']; ?></td>
            <td><?php print $fila['cantidad']; ?></td>
            <td>
                <a href="editar.php?id=<?php print $fila['id']; ?>">Editar</a>
                <a href="borrar.php?id=<?php print $fila['id']; ?>">Borrar</a>
            </td>
        </tr>
    <?php } ?>
</table>

<a href="nuevo.php">Añadir nuevo producto</a>
