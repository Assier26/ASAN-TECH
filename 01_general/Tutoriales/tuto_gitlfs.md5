
**Git LFS (Large File Storage)** es una extensión de Git diseñada para manejar archivos grandes de manera eficiente. 
En lugar de almacenar el archivo grande directamente en el repositorio, Git LFS lo reemplaza con un puntero 
(una referencia al archivo real) y almacena el archivo en un servidor remoto. 

Esto ayuda a mantener el repositorio liviano y rápido, incluso cuando se trabaja 
con archivos grandes como PDFs, videos, imágenes, etc.

Cómo usar **Git LFS en Windows 10** paso a paso:

---

### 1. **Instalar Git LFS**
   - Si ya tienes Git instalado en tu Windows 10, puedes instalar Git LFS de la siguiente manera:
     1. Descarga el instalador de Git LFS desde su sitio oficial: [https://git-lfs.github.com/](https://git-lfs.github.com/).
     2. Ejecuta el instalador y sigue las instrucciones.
     3. Una vez instalado, abre una terminal (Git Bash, Command Prompt o PowerShell) y verifica que Git LFS esté correctamente instalado:
        ```bash
        git lfs --version
        ```
        Esto debería mostrar la versión de Git LFS instalada.

---

### 2. **Habilitar Git LFS en tu repositorio**
   - Si ya tienes un repositorio Git, navega a la carpeta del repositorio en la terminal.
   - Ejecuta el siguiente comando para habilitar Git LFS en el repositorio:
     ```bash
     git lfs install
     ```
     Esto configura Git LFS para el repositorio actual.

---

### 3. **Seleccionar los archivos grandes que quieres manejar con Git LFS**
   - Para decirle a Git LFS qué tipo de archivos debe manejar, usa el comando `track`. Por ejemplo, si quieres manejar archivos PDF:
     ```bash
     git lfs track "*.pdf"
     ```
   - Esto crea o modifica un archivo llamado `.gitattributes` en tu repositorio, donde se especifica que los archivos PDF deben manejarse con Git LFS.

---

### 4. **Añadir y subir los archivos al repositorio**
   - Una vez configurado Git LFS, puedes añadir y subir archivos grandes como lo harías normalmente con Git:
     ```bash
     git add nombre_del_archivo.pdf
     git commit -m "Añado archivo PDF usando Git LFS"
     git push origin nombre_de_la_rama
     ```
   - Git LFS se encargará de reemplazar el archivo grande con un puntero y subirá el archivo real al servidor de LFS.

---

### 5. **Clonar un repositorio con Git LFS**
   - Si clonas un repositorio que usa Git LFS, los archivos grandes se descargarán automáticamente cuando los necesites (por ejemplo, al cambiar de rama o al hacer checkout de un archivo específico).
   - Para clonar el repositorio:
     ```bash
     git clone URL_DEL_REPOSITORIO
     ```
   - Si solo quieres descargar los punteros y no los archivos grandes (útil para revisar el código rápidamente), puedes usar:
     ```bash
     GIT_LFS_SKIP_SMUDGE=1 git clone URL_DEL_REPOSITORIO
     ```

---

### 6. **Verificar archivos gestionados por Git LFS**
   - Para ver qué archivos están siendo manejados por Git LFS en tu repositorio, puedes usar:
     ```bash
     git lfs ls-files
     ```
   - Esto mostrará una lista de archivos grandes que están siendo rastreados por Git LFS.

---

### 7. **Eliminar archivos grandes del historial (opcional)**
   - Si accidentalmente subiste un archivo grande sin Git LFS y quieres eliminarlo del historial de Git, puedes usar herramientas como `git filter-repo` o `BFG Repo-Cleaner`. Sin embargo, esto es avanzado y debe hacerse con cuidado, ya que reescribe el historial del repositorio.

---

### Resumen de comandos útiles
| Comando                         | Descripción                                   |
|---------------------------------|-----------------------------------------------|
| `git lfs install`               | Habilita Git LFS en el repositorio actual.    |
| `git lfs track "*.pdf"`         | Rastrea archivos PDF con Git LFS.             |
| `git lfs ls-files`              | Muestra los archivos gestionados por Git LFS. |
| `git add` y `git commit`        | Añade y confirma cambios como siempre.        |
| `git push`                      | Sube los cambios al repositorio remoto.       |

---

### Ventajas de usar Git LFS
- **Repositorios más livianos:** El repositorio principal no se llena con archivos grandes.
- **Rendimiento mejorado:** Las operaciones como clonar o hacer pull son más rápidas.
- **Fácil de usar:** Una vez configurado, Git LFS funciona de manera transparente.

---
