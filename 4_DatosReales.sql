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

/*---------------------------------------------------------------
                    MAESTROS DEL ITT 
  ---------------------------------------------------------------*/
/*---------------------------------------------------------------
                    PRIMER SEMESTRE
  ---------------------------------------------------------------*/

/* ---------- MAESTROS CÁLCULO DIFERENCIAL ---------- */
UPDATE Maestro SET Nombre = N'Julio Campos Morales'               WHERE Clave = 'DOC001'; 
UPDATE Maestro SET Nombre = N'Zenaido Antonio Aguilar De Leon'    WHERE Clave = 'DOC002'; 
UPDATE Maestro SET Nombre = N'Mariana Huizar Tejeda'              WHERE Clave = 'DOC003'; -- + Cálculo Integral + Cálculo Vectorial + Ecuaciones Diferenciales
UPDATE Maestro SET Nombre = N'Jose Gerardo Benjamín Mancilla Silva' WHERE Clave = 'DOC004'; -- + Álgebra Lineal
UPDATE Maestro SET Nombre = N'Selene Laces Valdiviezo'            WHERE Clave = 'DOC005'; -- + Cálculo Integral
UPDATE Maestro SET Nombre = N'Rogelio Escobedo Mitre'             WHERE Clave = 'DOC006'; -- + Álgebra Lineal + Taller de Sistemas Op.

/* ---------- MAESTROS FUNDAMENTOS DE PROGRAMACIÓN ---------- */
UPDATE Maestro SET Nombre = N'María Leticia Lomeli Briones'       WHERE Clave = 'DOC007'; -- + Taller de Ética + Cultura Empresarial
UPDATE Maestro SET Nombre = N'Lizeth Chavira Macias'              WHERE Clave = 'DOC008'; -- + Fund. Investigación + Mat. Discretas + Cultura Empresarial
UPDATE Maestro SET Nombre = N'José Adolfo Medina Cervantes'       WHERE Clave = 'DOC009'; -- + Fund. Investigación + Poo + Desarrollo Sustentable
UPDATE Maestro SET Nombre = N'Karina Aidee Romero Alvarado'       WHERE Clave = 'DOC010'; -- + Mat. Discretas

--INSERTAR LOS MAESTROS NUEVOS
INSERT INTO Maestro (Clave, Nombre)
SELECT v.Clave, v.Nombre
FROM (VALUES
    /* ---------- MAESTROS FUNDAMENTOS DE PROGRAMACIÓN ---------- */
    ('DOC011', N'Luz Elena Cortés Galvan'), -- + Poo + Estructura de Datos
    ('DOC012', N'José De Jesus Parra Galaviz'),
    ('DOC013', N'Marco Antonio Rodriguez Moreno'),
    /* ---------- MAESTROS FUNDAMENTOS DE INVESTIGACIÓN ---------- */
    ('DOC014', N'Claudia Negrete Sanchez'),-- + Mat. Discretas + Poo + Estructura de Datos
    ('DOC015', N'Gabriela Torres Beltrán'), -- + Poo
    ('DOC016', N'Claudia Ibeth Gonzalez Berrelleza'), -- + Fundamentos de Bases de Datos
    ('DOC017', N'Jesus Jaime Gonzalez Gonzalez'),
    ('DOC018', N'Martha Elena Pulido'), -- + Fundamentos de Ingeniería de Software + Ingeniería de Software
    /* ---------- MAESTROS TALLER DE ADMINISTRACIÓN ---------- */
    ('DOC019', N'Consuelo Fabiola Fausto Trujillo'),
    ('DOC020', N'Alma Sofia Flores Rivera'),
    ('DOC021', N'Marco Jorge Aquino'), -- + Arquitectura de Computadoras
    ('DOC022', N'Maria de los Angeles Quezada Cisnero'), -- + Tópicos Avanzados de Programación
    ('DOC023', N'Maria Isabel Renteria Lomeli'), -- + Cultura Empresarial
    ('DOC024', N'Luz Maria Lugo Mendez'),
    ('DOC025', N'Rosana Gutierrez Montoya'), -- + Mat. Discretas + Gestión de Proyectos de Software + Taller de Investigación II
    /* ---------- MAESTROS TALLER DE ÉTICA ---------- */
    ('DOC026', N'Celia Grisel Escobedo Aparicio'),
    ('DOC027', N'Cristina Cervantes Vivaldo'),
    ('DOC028', N'Claudia Selene Loreto Medina'),

    /*---------------------------------------------------------------
					    SEGUNDO SEMESTRE 
       ------------------------------------------------------------*/

    /* ---------- MAESTROS CÁLCULO INTEGRAL ---------- */
    ('DOC029', N'José Alfonso Romero Gandara'), -- + Cálculo Vectorial + Ecuaciones Diferenciales
    ('DOC030', N'Zenaido Antonio Aguilar de Leon'),
    ('DOC031', N'Cynthia Ivette Miramontes Ortega'),
    ('DOC032', N'José Armando Rocha Rocha'), -- + Cálculo Vectorial + Ecuaciones Diferenciales
    ('DOC033', N'José Enrique Montoya Lopez'),

    /* ---------- MAESTROS POO ---------- */
    ('DOC034', N'Alejandra Mancilla Soto'),
    ('DOC035', N'Ramón Antonio Castro Garcia'), -- + Fundamentos de Bases de Datos

    /* ---------- MAESTROS ÁLGEBRA LINEAL ---------- */
    ('DOC036', N'Virginia de la Garza Guadarrama'),
    
    /* ---------- MAESTROS CULTURA EMPRESARIAL ---------- */
    ('DOC037', N'Heidy Marianne Vazquez Espinosa'), -- + Contabilidad Financiera
    ('DOC038', N'Laura Angélica Cegobiano García'), -- + Fundamentos de Ingeniería de Software + Desarrollo Sustentable + Ingeniería de Software

    /* ---------- MAESTROS PROBABILIDAD Y ESTADÍSTICA ---------- */
    ('DOC039', N'Hector Carreón Ortiz'), -- + Métodos Numéricos
    ('DOC040', N'Susana Hetandez Toledo'),

    /* ---------- MAESTROS FÍSICA GENERAL ---------- */
    ('DOC041', N'Lucerito Zagal Salgado'), -- + Probabilidad y Estadística
    ('DOC042', N'Ashlee Evelin Robles Gallegos'),
    ('DOC043', N'Elam Moreno Mozo'),
    ('DOC044', N'María Eugenía Bermudez Jimenez'),

    /*---------------------------------------------------------------
					    TERCER SEMESTRE 
       ------------------------------------------------------------*/

    /* ---------- MAESTROS CÁLCULO VECTORIAL ---------- */
    ('DOC045', N'Jesus Luna Gonzales'),
    ('DOC046', N'Jesus Francisco Hernadez Aguilar'), -- + Ecuaciones Diferenciales

    /* ---------- MAESTROS QUÍMICA ---------- */
    ('DOC047', N'Juan Antonio Piña Acosta'),
    ('DOC048', N'Sandy Denisse Ramirez Zatarain'),
    ('DOC049', N'Hector Daniel Ibarra Prieto'),
    ('DOC050', N'Diego Saúl Vasquez Rios'),-- + Desarrollo Sustentable + Ingeniería de Software + Programación Lógica y Funcional + Gestión de Proyectos de Software
    ('DOC051', N'Luz María de la Rosa Romo'),

    /* ---------- MAESTROS INVESTIGACIÓN DE OP. ---------- */
    ('DOC052', N'Sergio Armando Bueno Martínez'),
    ('DOC053', N'Cristian Martina Rueda Arredondo'),

    /* ---------- MAESTROS PRINCIPIOS ELÉCTRICOS Y APLICACIONES DIGITALES ---------- */
    ('DOC054', N'Fernando Armando Villalbazo Gomez'),
    ('DOC055', N'Abel Murillo Montaño'),
    ('DOC056', N'Luis Gonzalo Montoya Villegas'),

    /*---------------------------------------------------------------
					CUARTO SEMESTRE 
   ------------------------------------------------------------*/

   /* ---------- MAESTROS ECUACIONES DIFERENCIALES ---------- */
   ('DOC057', N'Sonia Moreno Cabral'), -- + Álgebra Lineal
  
  /* ---------- MAESTROS TÓPICOS AVANZADOS DE PROGRAMACIÓN ---------- */
  ('DOC058', N'María Magdalena Serrano Ortega'),
  ('DOC059', N'Gabriela Lourdes Tapia Gonzalez'), -- +Taller de Bases de Datos + Administración de Bases de Datos + Taller de Investigación I

  /* ---------- MAESTROS MÉTODOS NÚMERICOS ---------- */
  ('DOC060', N'Martha Patricia Ochoa Velardez'),
  ('DOC061', N'Luis Maribel Guerrero'),

  /* ---------- MAESTROS FUNDAMENTOS DE BASES DE DATOS ---------- */
  ('DOC062', N'Diana Lisseth Bravo Castro'),
  
  /* ---------- MAESTROS SIMULACIÓN ---------- */
  ('DOC063', N'María Concepción Ibarra Gamiz'),
  ('DOC064', N'Juan José Rogelio Orozco Garibay'), -- + Taller de Bases de Datos

  /* ---------- MAESTROS ARQUITECTURA DE COMPUTADORAS ---------- */
  ('DOC065', N'Miguel Angel López Ramirez'),

  /*---------------------------------------------------------------
					QUINTO SEMESTRE 
   ------------------------------------------------------------*/

  /* ---------- MAESTROS GRAFICACIÓN ---------- */
  ('DOC066', N'Humberto Raiz Orozco'),
  ('DOC067', N'Cynthia Peraza Ramirez'),

  /* ---------- MAESTROS FUNDAMENTOS DE TELECOMUNICACIONES ---------- */
  ('DOC068', N'Sergio Contreras Hernandez'),
  ('DOC069', N'Christian Alonso Arenas Campis '), -- + Sistemas Operativos I + Redes de Computadoras

  /* ---------- MAESTROS SISTEMAS OPERATIVOS I ---------- */
  ('DOC070', N'Erasmo Estrada Peña'), -- + Lenguajes y Autómatas I + Lenguajes y Autómatas II

  /* ---------- MAESTROS TALLER DE BASE DE DATOS ---------- */
  ('DOC071', N'Rene Solis Reyes'), -- + Lenguaje de Interfaz + Sistemas Programables

  /* ---------- MAESTROS FUNDAMENTOS DE INGENIERÍA DE SOFTWARE ---------- */
  ('DOC072', N'Reynaldo Andres Salas Carmona'),
  
  /* ---------- MAESTROS DESARROLLO SUSTENTABLE ---------- */
  ('DOC073', N'Daniel Alfredo Loreto Gomez'),

  /*---------------------------------------------------------------
					SEXTO SEMESTRE 
   ------------------------------------------------------------*/

   /* ---------- MAESTROS LENGUAJES Y AUTÓMATAS I ---------- */
  ('DOC074', N'Luis Alfonso Gaxiola Vega'), -- + Lenguajes y Autómatas II + Programación Lógica y Funcional + Sistemas Programables

  /* ---------- MAESTROS REDES DE COMPUTADORAS ---------- */
  ('DOC075', N'Jesus Ricardo Palma Valdez'), -- + Comunicación y Enrutamiento en Redes de Datos
  ('DOC076', N'Fevrier Adolfo Valdez Acosta'),

  /* ---------- TALLER DE SISTEMAS OPERATIVOS ---------- */
  ('DOC077', N'Rodrigo Leonardo Reyes Osorio'),-- + Gestión de Proyectos de Software

  /* ---------- MAESTROS INGENIERÍA DE SOFTWARE ---------- */
  ('DOC078', N'Hector Javier Hinojosa Galván'),

  /*---------------------------------------------------------------
					SÉPTIMO SEMESTRE 
   ------------------------------------------------------------*/

  /* ---------- MAESTROS TALLER DE INVESTIGACIÓN I ---------- */
  ('DOC079', N'Daniela Adriana Sanchez Vizcarra'), 

  /* ---------- MAESTROS SISTEMAS PROGRAMABLES ---------- */
  ('DOC080', N'Hector Alonso Miramontes Miramontes'), -- + Administración de Redes

    /*---------------------------------------------------------------
					OCTAVO SEMESTRE 
   ------------------------------------------------------------*/

   /* ---------- MAESTROS PROGRAMACIÓN WEB ---------- */
   ('DOC081', N'Octavio Romero Flores'),
   ('DOC082', N'Jose Jonathan Perez Castro'),
   ('DOC083', N'Ray Brunett Parra Galaviz'),
   ('DOC084', N'Jose Mario García Valdez'),

   /* ---------- MAESTROS ADMINISTRACIÓN DE REDES ---------- */
   ('DOC085', N'Sergio Contreras Hernandez'),
   
   /* ---------- TALLER DE INVESTIGACIÓN II ---------- */
   ('DOC086', N'Bogart Yail Marquez Lobato'),

   /* ---------- INTELIGENCIA ARTIFICIAL ---------- */
   ('DOC087', N'Arnulfo Alanis Garza')

) AS v(Clave, Nombre)
WHERE NOT EXISTS (SELECT 1 FROM Maestro m WHERE m.Clave = v.Clave);