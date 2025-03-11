document.getElementById("serviceForm").addEventListener("submit", function (event) {
    event.preventDefault();

    const service = document.getElementById("service").value;

    fetch("backend.php", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: `service=${service}`,
    })
        .then((response) => response.text())
        .then((data) => {
            alert("Servicio contratado correctamente.");
            console.log(data);
        })
        .catch((error) => {
            console.error("Error:", error);
        });
});