-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS servicios;

-- Usar la base de datos
USE servicios;

-- Crear la tabla 'servicios'
CREATE TABLE IF NOT EXISTS servicios (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- Identificador único
    nombre VARCHAR(50) NOT NULL,        -- Nombre del servicio (ej: nextcloud, facturascript)
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Fecha de contratación (automática)
);

-- Insertar datos de ejemplo (opcional)
INSERT INTO servicios (nombre) VALUES ('nextcloud');
INSERT INTO servicios (nombre) VALUES ('facturascript');