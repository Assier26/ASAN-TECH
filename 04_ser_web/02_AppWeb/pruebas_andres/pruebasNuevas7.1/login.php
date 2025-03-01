<?php
session_start();
include('conexion.php');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nombre_usuario = $_POST['nombre_usuario'];
    $password = $_POST['password'];

    // Construimos la consulta SQL
    $sql = "SELECT * FROM usuarios WHERE nombre_usuario = '$nombre_usuario' AND password = '$password'";

    // Seguridad para evitar inyecciones SQL
    $sqlSegura = $conexion->real_escape_string($sql);

    // Almacenamos el resultado de la consulta en una variable
    $resultado = $conexion->query($sqlSegura);

    // Verificamos si el resultado tiene al menos una fila
    if ($resultado->num_rows > 0) {
        // Iniciamos sesión y almacenamos el nombre de usuario en una variable de sesión
        $_SESSION['nombre_usuario'] = $nombre_usuario;
        // Redireccionamos al panel de control
        header("Location: cpanel.php");
    } else {
        // Mensaje de error genérico (evita que los atacantes descubran usuarios existentes)
        echo "<script>alert('Usuario o contraseña incorrectos');</script>";
    }
}
?>
// Formulario de inicio de sesión
<form method="POST" action="">
    Usuario: <input type="text" name="nombre_usuario"><br>
    Contraseña: <input type="password" name="password"><br>
    <input type="submit" value="Login">
</form>
