# AsignacionMaestros

Estructura
- sql/        01_esquema -> 02_datos_ejemplo -> 03_cambios_de_horario (crea antes la BD: CREATE DATABASE AsignacionMaestros;)
- src/AsignacionMaestros.Core    Algoritmo y reglas (sin UI ni BD). Probado.
- src/AsignacionMaestros.Forms   Windows Forms (net8.0-windows) + acceso a SQL Server
- tests/AsignacionMaestros.Pruebas   Consola con pruebas: `dotnet run --project tests/AsignacionMaestros.Pruebas`

Pasos
1. Crear la base y correr los 3 scripts en orden.
2. Ajustar la cadena de conexión en src/AsignacionMaestros.Forms/Datos/Configuracion.cs
3. Abrir AsignacionMaestros.sln en Visual Studio 2022 y ejecutar el proyecto Forms.
