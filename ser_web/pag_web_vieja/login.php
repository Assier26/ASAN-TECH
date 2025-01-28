<?php
session_start();
include('conexion.php');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
<style>
    body {
        background-color: blue;
        color: white;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    flex-direction: column;
    }
    .moving-text {
        font-size: 24px;
        font-weight: bold;
        animation: move 10s infinite alternate;
    }
    @keyframes move {
        0% { transform: translateX(-200px); }
        100% { transform: translateX(200px); }
    }
form {
    background-color: rgba(255, 255, 255, 0.1);
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
    display: flex;
    flex-direction: column;
    align-items: center;
}
input[type="text"], input[type="password"] {
    padding: 10px;
    margin: 10px 0;
    border: none;
    border-radius: 5px;
    width: 100%;
    max-width: 300px;
}
input[type="submit"] {
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    background-color: white;
    color: blue;
    font-weight: bold;
    cursor: pointer;
    transition: background-color 0.3s, color 0.3s;
}
input[type="submit"]:hover {
    background-color: lightblue;
    color: white;
}
</style>
</head>
<body>
<?php

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
<div class="moving-text">ASAN-TECH</div>
<div class="moving-text">ASAN-TECH</div>
<form method="POST" action="">
    Usuario: <input type="text" name="nombre"><br>
    Contraseña: <input type="password" name="contrasena"><br>
    <input type="submit" value="Login">
</form>
