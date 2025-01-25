-- 1. Borrar la base de datos existente
DROP DATABASE IF EXISTS asan_tech;
-- CHUPAMINGAS
-- 2. Crear la base de datos
CREATE DATABASE asan_tech;
USE asan_tech;

-- 3. Crear la tabla 'clientes'
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    contrasena VARCHAR(15) NOT NULL,
);

-- 4. Crear la tabla 'servicios'
CREATE TABLE servicios (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    nombre_servicio VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATETIME,
    fecha_fin DATETIME,
    costo DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE
);

-- Ejemplo de datos iniciales (opcional)
/* INSERT INTO clientes (nombre, apellido, email, telefono, direccion) 
VALUES 
('Juan', 'Pérez', 'juan.perez@example.com', '123456789', 'Calle Falsa 123'),
('María', 'Gómez', 'maria.gomez@example.com', '987654321', 'Avenida Siempre Viva 456');

INSERT INTO servicios (id_cliente, nombre_servicio, descripcion, fecha_inicio, fecha_fin, costo) 
VALUES 
(1, 'Mantenimiento de Servidores', 'Revisión y limpieza de servidores', '2025-01-10', '2025-01-15', 500.00),
(2, 'Desarrollo Web', 'Creación de una página web corporativa', '2025-01-20', '2025-02-10', 1200.00); */
