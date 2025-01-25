<?php
session_start();
include('conexion.php');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nombre_usuario = $_POST['nombre'];
    $contrasena = $_POST['contrasena'];

    $sql = "SELECT * FROM usuarios WHERE nombre = '$nombre_usuario' AND contrasena = '$contrasena'";
    $resultado = $conexion->query($sql);

    if ($resultado->num_rows > 0) {
        $_SESSION['nombre'] = $nombre_usuario;
        header("Location: cpanel.php");
    } else {
        print "Credenciales incorrectas";
    }
}
?>

<form method="POST" action="">
    Usuario: <input type="text" name="nombre"><br>
    Contraseña: <input type="password" name="contrasena"><br>
    <input type="submit" value="Login">
</form>
