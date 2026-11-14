/* =====================================================================
   04_datos_reales.sql
   Datos de ejemplo con nombres reales de materias (tomadas del kardex) y
   nombres de maestros FICTICIOS

   ATENCION: este script BORRA todos los datos de las tablas (incluido el
   ejemplo de 02_datos_ejemplo.sql) y carga el conjunto nuevo.
   Se ejecuta en una sola transaccion: si algo falla, no queda nada a medias.
   Ejecutar despues de 1, 2 (opcional) y 3.
   ===================================================================== */
SET XACT_ABORT ON;
BEGIN TRANSACTION;
USE AsignacionMaestros

/* ---------- LIMPIEZA ---------- */
IF OBJECT_ID('BitacoraAsignacion', 'U') IS NOT NULL DELETE FROM BitacoraAsignacion;
DELETE FROM PaqueteMateria;
DELETE FROM MaestroMateriaBloque;
DELETE FROM Paquete;
DELETE FROM PeriodoDia;
DELETE FROM Periodo;
DELETE FROM Maestro;
DELETE FROM Materia;
DELETE FROM Bloque;
DELETE FROM Dia;

/* ---------- PERIODO, DIAS Y BLOQUES ---------- */
INSERT INTO Periodo (Clave, Nombre) VALUES (N'AGO-DIC 2026', N'Periodo agosto-diciembre 2026');

INSERT INTO Dia (IdDia, Nombre) VALUES (1,N'Lunes'),(2,N'Martes'),(3,N'Miércoles'),(4,N'Jueves'),(5,N'Viernes');

INSERT INTO PeriodoDia (IdPeriodo, IdDia)
SELECT p.IdPeriodo, d.IdDia FROM Periodo p CROSS JOIN Dia d WHERE p.Clave = N'AGO-DIC 2026' AND d.IdDia BETWEEN 1 AND 4;

INSERT INTO Bloque (IdBloque, HoraInicio, HoraFin) VALUES
 (1,'08:00','09:00'),(2,'09:00','10:00'),(3,'10:00','11:00'),(4,'11:00','12:00');

/* ---------- MATERIAS (kardex completo, 46) ---------- */
INSERT INTO Materia (Clave, Nombre) VALUES
 ('ACF-0901', N'Cálculo Diferencial'),   -- semestre 1
 ('AED-1285', N'Fundamentos de Programación'),   -- semestre 1
 ('ACC-0906', N'Fundamentos de Investigación'),   -- semestre 1
 ('SCH-1024', N'Taller de Administración'),   -- semestre 1
 ('ACA-0907', N'Taller de Ética'),   -- semestre 1
 ('AEF-1041', N'Matemáticas Discretas'),   -- semestre 1
 ('ACF-0902', N'Cálculo Integral'),   -- semestre 2
 ('AED-1286', N'Programación Orientada a Objetos'),   -- semestre 2
 ('ACF-0903', N'Álgebra Lineal'),   -- semestre 2
 ('SCC-1005', N'Cultura Empresarial'),   -- semestre 2
 ('AEF-1052', N'Probabilidad y Estadística'),   -- semestre 2
 ('SCF-1006', N'Física General'),   -- semestre 2
 ('ACF-0904', N'Cálculo Vectorial'),   -- semestre 3
 ('AED-1026', N'Estructura de Datos'),   -- semestre 3
 ('AEC-1058', N'Química'),   -- semestre 3
 ('AEC-1008', N'Contabilidad Financiera'),   -- semestre 3
 ('SCC-1013', N'Investigación de Operaciones'),   -- semestre 3
 ('SCD-1018', N'Principios Eléctricos y Aplicaciones Digitales'),   -- semestre 3
 ('ACF-0905', N'Ecuaciones Diferenciales'),   -- semestre 4
 ('SCD-1027', N'Tópicos Avanzados de Programación'),   -- semestre 4
 ('SCC-1017', N'Métodos Numéricos'),   -- semestre 4
 ('AEF-1031', N'Fundamentos de Bases de Datos'),   -- semestre 4
 ('SCD-1022', N'Simulación'),   -- semestre 4
 ('SCD-1003', N'Arquitectura de Computadoras'),   -- semestre 4
 ('SCC-1010', N'Graficación'),   -- semestre 5
 ('AEC-1034', N'Fundamentos de Telecomunicaciones'),   -- semestre 5
 ('AEC-1061', N'Sistemas Operativos I'),   -- semestre 5
 ('SCA-1025', N'Taller de Bases de Datos'),   -- semestre 5
 ('SCC-1007', N'Fundamentos de Ingeniería de Software'),   -- semestre 5
 ('ACD-0908', N'Desarrollo Sustentable'),   -- semestre 5
 ('SCD-1015', N'Lenguajes y Autómatas I'),   -- semestre 6
 ('SCD-1021', N'Redes de Computadoras'),   -- semestre 6
 ('SCA-1026', N'Taller de Sistemas Operativos'),   -- semestre 6
 ('SCB-1001', N'Administración de Bases de Datos'),   -- semestre 6
 ('SCD-1011', N'Ingeniería de Software'),   -- semestre 6
 ('SCC-1014', N'Lenguajes de Interfaz'),   -- semestre 6
 ('SCD-1016', N'Lenguajes y Autómatas II'),   -- semestre 7
 ('SCD-1004', N'Conmutación y Enrutamiento en Redes de Datos'),   -- semestre 7
 ('ACA-0909', N'Taller de Investigación I'),   -- semestre 7
 ('SCC-1019', N'Programación Lógica y Funcional'),   -- semestre 7
 ('SCG-1009', N'Gestión de Proyectos de Software'),   -- semestre 7
 ('SCC-1023', N'Sistemas Programables'),   -- semestre 7
 ('AEB-1055', N'Programación Web'),   -- semestre 8
 ('SCA-1002', N'Administración de Redes'),   -- semestre 8
 ('ACA-0910', N'Taller de Investigación II'),   -- semestre 8
 ('SCC-1002', N'Inteligencia Artificial');   -- semestre 8

/* ---------- MAESTROS (nombres ficticios) ---------- */
INSERT INTO Maestro (Clave, Nombre) VALUES
 ('DOC001', N'Mtro. Ricardo Salcedo Montoya'),
 ('DOC002', N'Dra. Patricia Esparza Lugo'),
 ('DOC003', N'Ing. Marco Antonio Zepeda Nava'),
 ('DOC004', N'Mtro. Javier Armenta Quiroz'),
 ('DOC005', N'Mtra. Verónica Ibarra Contreras'),
 ('DOC006', N'Ing. Luis Fernando Camacho Rivas'),
 ('DOC007', N'Dr. Alfonso Treviño Beltrán'),
 ('DOC008', N'Ing. Gabriela Montes Rentería'),
 ('DOC009', N'Ing. Héctor Manuel Valdez Ortega'),
 ('DOC010', N'Mtra. Daniela Robles Escamilla');

/* ---------- PAQUETES (grado = semestre) ---------- */
INSERT INTO Paquete (IdPeriodo, Grado, Grupo)
SELECT p.IdPeriodo, v.Grado, v.Grupo
FROM Periodo p CROSS JOIN (VALUES (5,'A'),(5,'B'),(5,'C'),(6,'A'),(6,'B'),(7,'A')) v(Grado, Grupo)
WHERE p.Clave = N'AGO-DIC 2026';

/* ---------- HORARIO DE GRUPOS (slots) ---------- */
-- ORDER BY v.n asegura que los Id se asignen en este orden (resultado repetible).
INSERT INTO PaqueteMateria (IdPaquete, IdPeriodo, IdMateria, IdBloque)
SELECT pa.IdPaquete, pa.IdPeriodo, ma.IdMateria, v.Bloque
FROM (VALUES
 (1,'5A','SCC-1007',1),
 (2,'5A','SCA-1025',2),
 (3,'5A','AEC-1061',3),
 (4,'5A','AEC-1034',4),
 (5,'5B','SCA-1025',1),
 (6,'5B','AEC-1061',2),
 (7,'5B','AEC-1034',3),
 (8,'5B','SCC-1007',4),
 (9,'5C','AEC-1061',1),
 (10,'5C','AEC-1034',2),
 (11,'5C','SCC-1007',3),
 (12,'5C','SCA-1025',4),
 (13,'6A','SCD-1011',1),
 (14,'6A','SCB-1001',2),
 (15,'6A','SCA-1026',3),
 (16,'6A','SCD-1021',4),
 (17,'6B','SCA-1026',1),
 (18,'6B','SCD-1021',2),
 (19,'6B','SCD-1011',3),
 (20,'6B','SCB-1001',4),
 (21,'7A','SCG-1009',1),
 (22,'7A','SCD-1016',2),
 (23,'7A','SCC-1019',3),
 (24,'7A','SCD-1004',4)
) v(n, Paquete, Materia, Bloque)
JOIN Periodo p  ON p.Clave = N'AGO-DIC 2026'
JOIN Paquete pa ON pa.IdPeriodo = p.IdPeriodo AND pa.Clave = v.Paquete
JOIN Materia ma ON ma.Clave = v.Materia
ORDER BY v.n;

/* ---------- DISPONIBILIDAD: que materia ofrece cada maestro y a que hora ---------- */
INSERT INTO MaestroMateriaBloque (IdPeriodo, IdMaestro, IdMateria, IdBloque)
SELECT p.IdPeriodo, mt.IdMaestro, ma.IdMateria, v.Bloque
FROM (VALUES
 ('DOC001','SCC-1007',1),
 ('DOC001','SCC-1007',2),
 ('DOC001','SCC-1007',3),
 ('DOC001','SCC-1007',4),
 ('DOC001','SCD-1011',1),
 ('DOC001','SCD-1011',2),
 ('DOC001','SCD-1011',3),
 ('DOC001','SCD-1011',4),
 ('DOC001','SCG-1009',1),
 ('DOC001','SCG-1009',2),
 ('DOC001','SCG-1009',3),
 ('DOC001','SCG-1009',4),
 ('DOC002','SCA-1025',2),
 ('DOC002','SCA-1025',3),
 ('DOC002','SCA-1025',4),
 ('DOC002','SCB-1001',2),
 ('DOC002','SCB-1001',3),
 ('DOC002','SCB-1001',4),
 ('DOC002','SCD-1016',2),
 ('DOC002','SCD-1016',3),
 ('DOC002','SCD-1016',4),
 ('DOC002','SCC-1019',2),
 ('DOC002','SCC-1019',3),
 ('DOC002','SCC-1019',4),
 ('DOC003','SCD-1021',1),
 ('DOC003','SCD-1021',3),
 ('DOC003','SCD-1004',1),
 ('DOC003','SCD-1004',3),
 ('DOC004','AEC-1061',1),
 ('DOC004','AEC-1061',2),
 ('DOC004','SCA-1026',1),
 ('DOC004','SCA-1026',2),
 ('DOC005','SCD-1011',1),
 ('DOC005','SCD-1011',2),
 ('DOC005','SCD-1011',3),
 ('DOC005','SCD-1011',4),
 ('DOC005','SCG-1009',1),
 ('DOC005','SCG-1009',2),
 ('DOC005','SCG-1009',3),
 ('DOC005','SCG-1009',4),
 ('DOC006','AEC-1061',3),
 ('DOC006','AEC-1061',4),
 ('DOC006','SCA-1026',3),
 ('DOC006','SCA-1026',4),
 ('DOC007','SCD-1016',1),
 ('DOC007','SCD-1016',2),
 ('DOC007','SCD-1016',3),
 ('DOC007','SCC-1019',1),
 ('DOC007','SCC-1019',2),
 ('DOC007','SCC-1019',3),
 ('DOC008','AEC-1034',1),
 ('DOC008','AEC-1034',2),
 ('DOC009','SCC-1007',1),
 ('DOC009','SCC-1007',2),
 ('DOC009','SCC-1007',3),
 ('DOC009','SCC-1007',4),
 ('DOC009','SCA-1025',1),
 ('DOC009','SCA-1025',2),
 ('DOC009','SCA-1025',3),
 ('DOC009','SCA-1025',4),
 ('DOC009','SCB-1001',1),
 ('DOC009','SCB-1001',2),
 ('DOC009','SCB-1001',3),
 ('DOC009','SCB-1001',4),
 ('DOC010','SCD-1021',1),
 ('DOC010','SCD-1021',2),
 ('DOC010','SCD-1021',3),
 ('DOC010','SCD-1021',4),
 ('DOC010','SCD-1004',1),
 ('DOC010','SCD-1004',2),
 ('DOC010','SCD-1004',3),
 ('DOC010','SCD-1004',4),
 ('DOC010','AEC-1034',1),
 ('DOC010','AEC-1034',2),
 ('DOC010','AEC-1034',3),
 ('DOC010','AEC-1034',4)
) v(Maestro, Materia, Bloque)
JOIN Periodo p  ON p.Clave = N'AGO-DIC 2026'
JOIN Maestro mt ON mt.Clave = v.Maestro
JOIN Materia ma ON ma.Clave = v.Materia;

COMMIT TRANSACTION;
GO

/* ---------- VERIFICACION: cada fila debe coincidir con 'Esperado' ---------- */
SELECT 'Materias' AS Tabla, COUNT(*) AS Filas, 46 AS Esperado FROM Materia
UNION ALL SELECT 'Maestros',        COUNT(*), 10 FROM Maestro
UNION ALL SELECT 'Paquetes',        COUNT(*), 6  FROM Paquete
UNION ALL SELECT 'Slots',           COUNT(*), 24 FROM PaqueteMateria
UNION ALL SELECT 'Disponibilidad',  COUNT(*), 76 FROM MaestroMateriaBloque;
GO

/* ---------- PARA PONER LOS NOMBRES REALES DE LOS MAESTROS ---------- */
-- UPDATE Maestro SET Nombre = N'Nombre real aqui' WHERE Clave = 'DOC001';
-- Nomas que me da flojera jeje