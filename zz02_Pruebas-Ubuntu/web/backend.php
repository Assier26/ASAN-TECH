<?php
// Conectar a la base de datos
$servername = "localhost";
$username = "root";
$password = "password";
$dbname = "servicios";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

// Recibir datos del formulario
$service = $_POST['service'];

// Guardar en la base de datos
$sql = "INSERT INTO servicios (nombre) VALUES ('$service')";
if ($conn->query($sql) === TRUE) {
    echo "Servicio contratado correctamente.";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

// Ejecutar playbook de Ansible
$output = shell_exec("ansible-playbook -i /ruta/al/inventory /ruta/al/playbook-deploy.yml --extra-vars 'servicio=$service'");
echo "<pre>$output</pre>";

$conn->close();
?>