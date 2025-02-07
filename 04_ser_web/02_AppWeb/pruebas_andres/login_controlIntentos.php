
<?php
session_set_cookie_params([
    'httponly' => true,
    'secure' => isset($_SERVER['HTTPS']), // Solo en HTTPS
    'samesite' => 'Strict'
]);
session_start();

include('conexion.php');

// Límite de intentos de inicio de sesión
$limite_intentos = 5;
$bloqueo_minutos = 15;

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nombre_usuario = trim($_POST['nombre']);
    $contrasena = trim($_POST['contrasena']);

    if (!empty($nombre_usuario) && !empty($contrasena)) {
        // Verificar intentos fallidos
        if ($stmt = $conexion->prepare("SELECT contrasena, intentos, ultimo_intento FROM clientes WHERE nombre = ?")) {
            $stmt->bind_param("s", $nombre_usuario);
            $stmt->execute();
            $stmt->store_result();

            if ($stmt->num_rows > 0) {
                $stmt->bind_result($hash, $intentos, $ultimo_intento);
                $stmt->fetch();

                // Comprobar si el usuario está bloqueado
                if ($intentos >= $limite_intentos && (time() - strtotime($ultimo_intento)) < ($bloqueo_minutos * 60)) {
                    header("Location: login.php?error=Cuenta bloqueada. Intenta en $bloqueo_minutos minutos.");
                    exit();
                }

                if (password_verify($contrasena, $hash)) {
                    $_SESSION['nombre'] = $nombre_usuario;
                    $stmt->close();
                    
                    // Reiniciar intentos fallidos en la base de datos
                    $stmt = $conexion->prepare("UPDATE clientes SET intentos = 0 WHERE nombre = ?");
                    $stmt->bind_param("s", $nombre_usuario);
                    $stmt->execute();
                    
                    header("Location: cpanel.php");
                    exit();
                } else {
                    // Incrementar intentos fallidos
                    $stmt->close();
                    $stmt = $conexion->prepare("UPDATE clientes SET intentos = intentos + 1, ultimo_intento = NOW() WHERE nombre = ?");
                    $stmt->bind_param("s", $nombre_usuario);
                    $stmt->execute();
                    header("Location: login.php?error=Credenciales incorrectas.");
                    exit();
                }
            } else {
                header("Location: login.php?error=Credenciales incorrectas.");
                exit();
            }
            $stmt->close();
        }
    }
    $conexion->close();
}
?>

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
    
    <?php if (isset($_GET['error'])): ?>
        <p style="color:red;"> <?= htmlspecialchars($_GET['error']) ?> </p>
    <?php endif; ?>
    
    <form method="POST" action="">
        <label for="nombre">Nombre de usuario:</label><br>
        <input type="text" name="nombre" id="nombre" required><br><br>

        <label for="contrasena">Contraseña:</label><br>
        <input type="password" name="contrasena" id="contrasena" required><br><br>

        <input type="submit" value="Iniciar sesión">
    </form>

    <section id="volver-inicio">
        <form method="POST" action="index.html">
            <button type="submit" style="background-color: red; color: white; padding: 10px 20px; border: none; cursor: pointer;">Volver a inicio</button>
        </form>
    </section>
</body>
</html>