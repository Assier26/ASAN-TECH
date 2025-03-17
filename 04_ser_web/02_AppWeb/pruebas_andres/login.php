<?php
session_start(); // Inicia la sesión para manejar usuarios logueados
include('conexion.php'); // Conexión a la base de datos


/* - Límite de intentos de inicio de sesión
$limite_intentos = 5;
$bloqueo_minutos = 15;
*/
/* - INYECCIÓN SQL
// Conectar a la BBDD
$sql = "INSERT INTO comentario(parent_comentario_id,comment,comment_sender_name,date) VALUES ( 11, 'es un comentario', 'maria','" . $date . "')";

// Seguridad para evitar inyecciones SQL
$sqlSeguro = $mysqli->real_escape_string($sql);

    // Ejecutar la consulta
    if ($mysqli->query($sqlSeguro) === TRUE) {
        echo "Registro insertado correctamente.";
    } else {
        echo "Error al insertar el registro: " . $mysqli->error;
    }


*/







if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Obtiene y limpia los datos enviados por el formulario
    $nombre_usuario = trim($_POST['nombre']);
    $contrasena = trim($_POST['contrasena']);


    // Validar si los campos no están vacíos
    if (!empty($nombre_usuario) && !empty($contrasena)) {
        // Preparar la consulta SQL para evitar inyección SQL
        if ($stmt = $conexion->prepare("SELECT contrasena FROM clientes WHERE nombre = ?")) {
            $stmt->bind_param("s", $nombre_usuario); // Asigna el parámetro de forma segura
            $stmt->execute();
            $stmt->store_result();

            // Comprobamos si el usuario existe en la base de datos
            if ($stmt->num_rows > 0) {
                $stmt->bind_result($hash); // Vincula el hash de la contraseña obtenida
                $stmt->fetch();

                // Verificamos la contraseña usando password_verify (seguro)
                if (password_verify($contrasena, $hash)) {
                    $_SESSION['nombre'] = $nombre_usuario; // Guarda el nombre en la sesión
                    header("Location: cpanel.php"); // Redirige al panel de control
                    exit(); // Detiene la ejecución del script
                } else {
                    // Mensaje de error genérico (evita que los atacantes descubran usuarios existentes)
                    echo "<script>alert('Usuario o contraseña incorrectos');</script>";
                }
            } else {
                // Mensaje de error genérico (en lugar de "usuario no encontrado")
                echo "<script>alert('Usuario o contraseña incorrectos');</script>";
            }
            
            // Cierra la consulta para liberar memoria
            $stmt->close();
        } else {
            // En caso de fallo en la preparación de la consulta
            die("Error en la consulta SQL.");
        }
    }
    // Cierra la conexión a la base de datos
    $conexion->close();
}
?>

<!-- Aquí empieza el HTML -->
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>Login</h1>
    <!-- Formulario de Login -->
    <form method="POST" action="">
        <!-- Pedimos el nombre de usuario -->
        <label for="nombre">Nombre de usuario:</label><br>
        <input type="text" name="nombre" id="nombre" required><br><br>
        <!-- Pedimos la contraseña -->
        <label for="contrasena">Contraseña:</label><br>
        <input type="password" name="contrasena" id="contrasena" required><br><br>
        <!-- Botón para enviar el formulario -->
        <input type="submit" value="Iniciar sesión">
    </form>
    <!-- Botón para volver a inicio -->
    <section id="volver-inicio">
        <form method="POST" action="index.html">
            <button type="submit" style="background-color: red; color: white; padding: 10px 20px; border: none; cursor: pointer;">Volver a inicio</button>
        </form>
    </section>
</body>
</html>
