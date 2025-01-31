#de momento no se esta usando 
<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Recoger los datos del formulario
    $nombre = escapeshellarg($_POST['nombre']);
    $imagen = escapeshellarg($_POST['imagen']);
    $puerto = escapeshellarg($_POST['puerto']);
    $volumen = isset($_POST['volumen']) ? escapeshellarg($_POST['volumen']) : '';

    // Comando de Docker
    $comando = "docker run -d -p $puerto -v $volumen --name $nombre $imagen";

    // Ejecutar el comando
    $output = shell_exec($comando);

    if ($output === null) {
        echo "Hubo un error al crear el contenedor.";
    } else {
        echo "Contenedor '$nombre' creado exitosamente con la imagen '$imagen'.";
    }
}
?>
