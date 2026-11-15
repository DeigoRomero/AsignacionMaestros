/* =====================================================================
   05_disponibilidad.sql
   Disponibilidad (MaestroMateriaBloque) de los maestros de 04_datos_reales.sql.

   - Materias de cada maestro: encabezados de seccion + comentarios "+ ..." del script de Angie.
   - Horas: ALEATORIAS pero repetibles (semilla 2026). Cada maestro tiene una ventana
     de horas deseada (ej. 08-10, 10-12 o todo el dia) y es la misma para todas sus materias.
   - Cambiar la semilla en el generador da otra distribucion; el algoritmo funciona con cualquiera.

   EJECUTAR DESPUES de 04_datos_reales.sql. Es seguro repetirlo: limpia y vuelve a cargar.
   ===================================================================== */
USE AsignacionMaestros;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;

EXEC sp_set_session_context @key = N'Origen', @value = N'Limpieza';

/* 1) Quitar asignaciones previas (la llave foranea no deja borrar disponibilidad en uso) */
UPDATE PaqueteMateria
SET    IdMaestro = NULL, Estado = 'Pendiente', MotivoPendiente = NULL
WHERE  IdMaestro IS NOT NULL OR MotivoPendiente IS NOT NULL;

/* 2) Quitar la disponibilidad de ejemplo anterior (era de los 10 maestros ficticios) */
DELETE FROM MaestroMateriaBloque;

/* 3) Unificar personas repetidas: la misma persona tenia dos claves.
      DOC030 (Zenaido Antonio Aguilar) -> sus materias quedan en DOC002
      DOC085 (Sergio Contreras Hernandez) -> sus materias quedan en DOC068
   Con dos claves, el sistema podria ponerla en dos grupos a la misma hora. */
DELETE FROM Maestro WHERE Clave IN ('DOC030', 'DOC085');

/* 4) Quitar espacios sobrantes en los nombres (ej. 'Campis ') */
UPDATE Maestro SET Nombre = LTRIM(RTRIM(Nombre));

/* 5) Disponibilidad: (85 maestros, 151 pares maestro-materia, 450 filas) */
INSERT INTO MaestroMateriaBloque (IdPeriodo, IdMaestro, IdMateria, IdBloque)
SELECT p.IdPeriodo, mt.IdMaestro, ma.IdMateria, v.Bloque
FROM (VALUES
 -- DOC001 Julio Campos Morales · horario 08-12 · 1 materia(s)
 ('DOC001','ACF-0901',1),
 ('DOC001','ACF-0901',2),
 ('DOC001','ACF-0901',3),
 ('DOC001','ACF-0901',4),
 -- DOC002 Zenaido Antonio Aguilar De Leon · horario 08-11 · 2 materia(s)
 ('DOC002','ACF-0901',1),
 ('DOC002','ACF-0901',2),
 ('DOC002','ACF-0901',3),
 ('DOC002','ACF-0902',1),
 ('DOC002','ACF-0902',2),
 ('DOC002','ACF-0902',3),
 -- DOC003 Mariana Huizar Tejeda · horario 08-11 · 4 materia(s)
 ('DOC003','ACF-0901',1),
 ('DOC003','ACF-0901',2),
 ('DOC003','ACF-0901',3),
 ('DOC003','ACF-0902',1),
 ('DOC003','ACF-0902',2),
 ('DOC003','ACF-0902',3),
 ('DOC003','ACF-0904',1),
 ('DOC003','ACF-0904',2),
 ('DOC003','ACF-0904',3),
 ('DOC003','ACF-0905',1),
 ('DOC003','ACF-0905',2),
 ('DOC003','ACF-0905',3),
 -- DOC004 Jose Gerardo Benjamín Mancilla Silva · horario 09-11 · 2 materia(s)
 ('DOC004','ACF-0901',2),
 ('DOC004','ACF-0901',3),
 ('DOC004','ACF-0903',2),
 ('DOC004','ACF-0903',3),
 -- DOC005 Selene Laces Valdiviezo · horario 08-12 · 2 materia(s)
 ('DOC005','ACF-0901',1),
 ('DOC005','ACF-0901',2),
 ('DOC005','ACF-0901',3),
 ('DOC005','ACF-0901',4),
 ('DOC005','ACF-0902',1),
 ('DOC005','ACF-0902',2),
 ('DOC005','ACF-0902',3),
 ('DOC005','ACF-0902',4),
 -- DOC006 Rogelio Escobedo Mitre · horario 08-12 · 3 materia(s)
 ('DOC006','ACF-0901',1),
 ('DOC006','ACF-0901',2),
 ('DOC006','ACF-0901',3),
 ('DOC006','ACF-0901',4),
 ('DOC006','ACF-0903',1),
 ('DOC006','ACF-0903',2),
 ('DOC006','ACF-0903',3),
 ('DOC006','ACF-0903',4),
 ('DOC006','SCA-1026',1),
 ('DOC006','SCA-1026',2),
 ('DOC006','SCA-1026',3),
 ('DOC006','SCA-1026',4),
 -- DOC007 María Leticia Lomeli Briones · horario 09-12 · 3 materia(s)
 ('DOC007','AED-1285',2),
 ('DOC007','AED-1285',3),
 ('DOC007','AED-1285',4),
 ('DOC007','ACA-0907',2),
 ('DOC007','ACA-0907',3),
 ('DOC007','ACA-0907',4),
 ('DOC007','SCC-1005',2),
 ('DOC007','SCC-1005',3),
 ('DOC007','SCC-1005',4),
 -- DOC008 Lizeth Chavira Macias · horario 09-12 · 4 materia(s)
 ('DOC008','AED-1285',2),
 ('DOC008','AED-1285',3),
 ('DOC008','AED-1285',4),
 ('DOC008','ACC-0906',2),
 ('DOC008','ACC-0906',3),
 ('DOC008','ACC-0906',4),
 ('DOC008','AEF-1041',2),
 ('DOC008','AEF-1041',3),
 ('DOC008','AEF-1041',4),
 ('DOC008','SCC-1005',2),
 ('DOC008','SCC-1005',3),
 ('DOC008','SCC-1005',4),
 -- DOC009 José Adolfo Medina Cervantes · horario 09-11 · 4 materia(s)
 ('DOC009','AED-1285',2),
 ('DOC009','AED-1285',3),
 ('DOC009','ACC-0906',2),
 ('DOC009','ACC-0906',3),
 ('DOC009','AED-1286',2),
 ('DOC009','AED-1286',3),
 ('DOC009','ACD-0908',2),
 ('DOC009','ACD-0908',3),
 -- DOC010 Karina Aidee Romero Alvarado · horario 09-12 · 2 materia(s)
 ('DOC010','AED-1285',2),
 ('DOC010','AED-1285',3),
 ('DOC010','AED-1285',4),
 ('DOC010','AEF-1041',2),
 ('DOC010','AEF-1041',3),
 ('DOC010','AEF-1041',4),
 -- DOC011 Luz Elena Cortés Galvan · horario 08-10 · 3 materia(s)
 ('DOC011','AED-1285',1),
 ('DOC011','AED-1285',2),
 ('DOC011','AED-1286',1),
 ('DOC011','AED-1286',2),
 ('DOC011','AED-1026',1),
 ('DOC011','AED-1026',2),
 -- DOC012 José De Jesus Parra Galaviz · horario 08-10 · 1 materia(s)
 ('DOC012','AED-1285',1),
 ('DOC012','AED-1285',2),
 -- DOC013 Marco Antonio Rodriguez Moreno · horario 08-10 · 1 materia(s)
 ('DOC013','AED-1285',1),
 ('DOC013','AED-1285',2),
 -- DOC014 Claudia Negrete Sanchez · horario 09-12 · 4 materia(s)
 ('DOC014','ACC-0906',2),
 ('DOC014','ACC-0906',3),
 ('DOC014','ACC-0906',4),
 ('DOC014','AEF-1041',2),
 ('DOC014','AEF-1041',3),
 ('DOC014','AEF-1041',4),
 ('DOC014','AED-1286',2),
 ('DOC014','AED-1286',3),
 ('DOC014','AED-1286',4),
 ('DOC014','AED-1026',2),
 ('DOC014','AED-1026',3),
 ('DOC014','AED-1026',4),
 -- DOC015 Gabriela Torres Beltrán · horario 08-12 · 2 materia(s)
 ('DOC015','ACC-0906',1),
 ('DOC015','ACC-0906',2),
 ('DOC015','ACC-0906',3),
 ('DOC015','ACC-0906',4),
 ('DOC015','AED-1286',1),
 ('DOC015','AED-1286',2),
 ('DOC015','AED-1286',3),
 ('DOC015','AED-1286',4),
 -- DOC016 Claudia Ibeth Gonzalez Berrelleza · horario 09-12 · 2 materia(s)
 ('DOC016','ACC-0906',2),
 ('DOC016','ACC-0906',3),
 ('DOC016','ACC-0906',4),
 ('DOC016','AEF-1031',2),
 ('DOC016','AEF-1031',3),
 ('DOC016','AEF-1031',4),
 -- DOC017 Jesus Jaime Gonzalez Gonzalez · horario 08-12 · 1 materia(s)
 ('DOC017','ACC-0906',1),
 ('DOC017','ACC-0906',2),
 ('DOC017','ACC-0906',3),
 ('DOC017','ACC-0906',4),
 -- DOC018 Martha Elena Pulido · horario 09-11 · 3 materia(s)
 ('DOC018','ACC-0906',2),
 ('DOC018','ACC-0906',3),
 ('DOC018','SCC-1007',2),
 ('DOC018','SCC-1007',3),
 ('DOC018','SCD-1011',2),
 ('DOC018','SCD-1011',3),
 -- DOC019 Consuelo Fabiola Fausto Trujillo · horario 08-11 · 1 materia(s)
 ('DOC019','SCH-1024',1),
 ('DOC019','SCH-1024',2),
 ('DOC019','SCH-1024',3),
 -- DOC020 Alma Sofia Flores Rivera · horario 09-11 · 1 materia(s)
 ('DOC020','SCH-1024',2),
 ('DOC020','SCH-1024',3),
 -- DOC021 Marco Jorge Aquino · horario 08-10 · 2 materia(s)
 ('DOC021','SCH-1024',1),
 ('DOC021','SCH-1024',2),
 ('DOC021','SCD-1003',1),
 ('DOC021','SCD-1003',2),
 -- DOC022 Maria de los Angeles Quezada Cisnero · horario 08-10 · 2 materia(s)
 ('DOC022','SCH-1024',1),
 ('DOC022','SCH-1024',2),
 ('DOC022','SCD-1027',1),
 ('DOC022','SCD-1027',2),
 -- DOC023 Maria Isabel Renteria Lomeli · horario 08-12 · 2 materia(s)
 ('DOC023','SCH-1024',1),
 ('DOC023','SCH-1024',2),
 ('DOC023','SCH-1024',3),
 ('DOC023','SCH-1024',4),
 ('DOC023','SCC-1005',1),
 ('DOC023','SCC-1005',2),
 ('DOC023','SCC-1005',3),
 ('DOC023','SCC-1005',4),
 -- DOC024 Luz Maria Lugo Mendez · horario 08-12 · 1 materia(s)
 ('DOC024','SCH-1024',1),
 ('DOC024','SCH-1024',2),
 ('DOC024','SCH-1024',3),
 ('DOC024','SCH-1024',4),
 -- DOC025 Rosana Gutierrez Montoya · horario 10-12 · 4 materia(s)
 ('DOC025','SCH-1024',3),
 ('DOC025','SCH-1024',4),
 ('DOC025','AEF-1041',3),
 ('DOC025','AEF-1041',4),
 ('DOC025','SCG-1009',3),
 ('DOC025','SCG-1009',4),
 ('DOC025','ACA-0910',3),
 ('DOC025','ACA-0910',4),
 -- DOC026 Celia Grisel Escobedo Aparicio · horario 10-12 · 1 materia(s)
 ('DOC026','ACA-0907',3),
 ('DOC026','ACA-0907',4),
 -- DOC027 Cristina Cervantes Vivaldo · horario 09-11 · 1 materia(s)
 ('DOC027','ACA-0907',2),
 ('DOC027','ACA-0907',3),
 -- DOC028 Claudia Selene Loreto Medina · horario 10-12 · 1 materia(s)
 ('DOC028','ACA-0907',3),
 ('DOC028','ACA-0907',4),
 -- DOC029 José Alfonso Romero Gandara · horario 08-11 · 3 materia(s)
 ('DOC029','ACF-0902',1),
 ('DOC029','ACF-0902',2),
 ('DOC029','ACF-0902',3),
 ('DOC029','ACF-0904',1),
 ('DOC029','ACF-0904',2),
 ('DOC029','ACF-0904',3),
 ('DOC029','ACF-0905',1),
 ('DOC029','ACF-0905',2),
 ('DOC029','ACF-0905',3),
 -- DOC031 Cynthia Ivette Miramontes Ortega · horario 08-12 · 1 materia(s)
 ('DOC031','ACF-0902',1),
 ('DOC031','ACF-0902',2),
 ('DOC031','ACF-0902',3),
 ('DOC031','ACF-0902',4),
 -- DOC032 José Armando Rocha Rocha · horario 08-12 · 3 materia(s)
 ('DOC032','ACF-0902',1),
 ('DOC032','ACF-0902',2),
 ('DOC032','ACF-0902',3),
 ('DOC032','ACF-0902',4),
 ('DOC032','ACF-0904',1),
 ('DOC032','ACF-0904',2),
 ('DOC032','ACF-0904',3),
 ('DOC032','ACF-0904',4),
 ('DOC032','ACF-0905',1),
 ('DOC032','ACF-0905',2),
 ('DOC032','ACF-0905',3),
 ('DOC032','ACF-0905',4),
 -- DOC033 José Enrique Montoya Lopez · horario 09-12 · 1 materia(s)
 ('DOC033','ACF-0902',2),
 ('DOC033','ACF-0902',3),
 ('DOC033','ACF-0902',4),
 -- DOC034 Alejandra Mancilla Soto · horario 08-12 · 1 materia(s)
 ('DOC034','AED-1286',1),
 ('DOC034','AED-1286',2),
 ('DOC034','AED-1286',3),
 ('DOC034','AED-1286',4),
 -- DOC035 Ramón Antonio Castro Garcia · horario 08-11 · 2 materia(s)
 ('DOC035','AED-1286',1),
 ('DOC035','AED-1286',2),
 ('DOC035','AED-1286',3),
 ('DOC035','AEF-1031',1),
 ('DOC035','AEF-1031',2),
 ('DOC035','AEF-1031',3),
 -- DOC036 Virginia de la Garza Guadarrama · horario 10-12 · 1 materia(s)
 ('DOC036','ACF-0903',3),
 ('DOC036','ACF-0903',4),
 -- DOC037 Heidy Marianne Vazquez Espinosa · horario 08-10 · 2 materia(s)
 ('DOC037','SCC-1005',1),
 ('DOC037','SCC-1005',2),
 ('DOC037','AEC-1008',1),
 ('DOC037','AEC-1008',2),
 -- DOC038 Laura Angélica Cegobiano García · horario 09-12 · 4 materia(s)
 ('DOC038','SCC-1005',2),
 ('DOC038','SCC-1005',3),
 ('DOC038','SCC-1005',4),
 ('DOC038','SCC-1007',2),
 ('DOC038','SCC-1007',3),
 ('DOC038','SCC-1007',4),
 ('DOC038','ACD-0908',2),
 ('DOC038','ACD-0908',3),
 ('DOC038','ACD-0908',4),
 ('DOC038','SCD-1011',2),
 ('DOC038','SCD-1011',3),
 ('DOC038','SCD-1011',4),
 -- DOC039 Hector Carreón Ortiz · horario 08-12 · 2 materia(s)
 ('DOC039','AEF-1052',1),
 ('DOC039','AEF-1052',2),
 ('DOC039','AEF-1052',3),
 ('DOC039','AEF-1052',4),
 ('DOC039','SCC-1017',1),
 ('DOC039','SCC-1017',2),
 ('DOC039','SCC-1017',3),
 ('DOC039','SCC-1017',4),
 -- DOC040 Susana Hetandez Toledo · horario 08-10 · 1 materia(s)
 ('DOC040','AEF-1052',1),
 ('DOC040','AEF-1052',2),
 -- DOC041 Lucerito Zagal Salgado · horario 08-12 · 2 materia(s)
 ('DOC041','SCF-1006',1),
 ('DOC041','SCF-1006',2),
 ('DOC041','SCF-1006',3),
 ('DOC041','SCF-1006',4),
 ('DOC041','AEF-1052',1),
 ('DOC041','AEF-1052',2),
 ('DOC041','AEF-1052',3),
 ('DOC041','AEF-1052',4),
 -- DOC042 Ashlee Evelin Robles Gallegos · horario 08-11 · 1 materia(s)
 ('DOC042','SCF-1006',1),
 ('DOC042','SCF-1006',2),
 ('DOC042','SCF-1006',3),
 -- DOC043 Elam Moreno Mozo · horario 08-11 · 1 materia(s)
 ('DOC043','SCF-1006',1),
 ('DOC043','SCF-1006',2),
 ('DOC043','SCF-1006',3),
 -- DOC044 María Eugenía Bermudez Jimenez · horario 09-12 · 1 materia(s)
 ('DOC044','SCF-1006',2),
 ('DOC044','SCF-1006',3),
 ('DOC044','SCF-1006',4),
 -- DOC045 Jesus Luna Gonzales · horario 08-11 · 1 materia(s)
 ('DOC045','ACF-0904',1),
 ('DOC045','ACF-0904',2),
 ('DOC045','ACF-0904',3),
 -- DOC046 Jesus Francisco Hernadez Aguilar · horario 08-12 · 2 materia(s)
 ('DOC046','ACF-0904',1),
 ('DOC046','ACF-0904',2),
 ('DOC046','ACF-0904',3),
 ('DOC046','ACF-0904',4),
 ('DOC046','ACF-0905',1),
 ('DOC046','ACF-0905',2),
 ('DOC046','ACF-0905',3),
 ('DOC046','ACF-0905',4),
 -- DOC047 Juan Antonio Piña Acosta · horario 08-11 · 1 materia(s)
 ('DOC047','AEC-1058',1),
 ('DOC047','AEC-1058',2),
 ('DOC047','AEC-1058',3),
 -- DOC048 Sandy Denisse Ramirez Zatarain · horario 08-10 · 1 materia(s)
 ('DOC048','AEC-1058',1),
 ('DOC048','AEC-1058',2),
 -- DOC049 Hector Daniel Ibarra Prieto · horario 09-12 · 1 materia(s)
 ('DOC049','AEC-1058',2),
 ('DOC049','AEC-1058',3),
 ('DOC049','AEC-1058',4),
 -- DOC050 Diego Saúl Vasquez Rios · horario 08-11 · 5 materia(s)
 ('DOC050','AEC-1058',1),
 ('DOC050','AEC-1058',2),
 ('DOC050','AEC-1058',3),
 ('DOC050','ACD-0908',1),
 ('DOC050','ACD-0908',2),
 ('DOC050','ACD-0908',3),
 ('DOC050','SCD-1011',1),
 ('DOC050','SCD-1011',2),
 ('DOC050','SCD-1011',3),
 ('DOC050','SCC-1019',1),
 ('DOC050','SCC-1019',2),
 ('DOC050','SCC-1019',3),
 ('DOC050','SCG-1009',1),
 ('DOC050','SCG-1009',2),
 ('DOC050','SCG-1009',3),
 -- DOC051 Luz María de la Rosa Romo · horario 10-12 · 1 materia(s)
 ('DOC051','AEC-1058',3),
 ('DOC051','AEC-1058',4),
 -- DOC052 Sergio Armando Bueno Martínez · horario 08-12 · 1 materia(s)
 ('DOC052','SCC-1013',1),
 ('DOC052','SCC-1013',2),
 ('DOC052','SCC-1013',3),
 ('DOC052','SCC-1013',4),
 -- DOC053 Cristian Martina Rueda Arredondo · horario 08-11 · 1 materia(s)
 ('DOC053','SCC-1013',1),
 ('DOC053','SCC-1013',2),
 ('DOC053','SCC-1013',3),
 -- DOC054 Fernando Armando Villalbazo Gomez · horario 10-12 · 1 materia(s)
 ('DOC054','SCD-1018',3),
 ('DOC054','SCD-1018',4),
 -- DOC055 Abel Murillo Montaño · horario 08-11 · 1 materia(s)
 ('DOC055','SCD-1018',1),
 ('DOC055','SCD-1018',2),
 ('DOC055','SCD-1018',3),
 -- DOC056 Luis Gonzalo Montoya Villegas · horario 08-11 · 1 materia(s)
 ('DOC056','SCD-1018',1),
 ('DOC056','SCD-1018',2),
 ('DOC056','SCD-1018',3),
 -- DOC057 Sonia Moreno Cabral · horario 08-12 · 2 materia(s)
 ('DOC057','ACF-0905',1),
 ('DOC057','ACF-0905',2),
 ('DOC057','ACF-0905',3),
 ('DOC057','ACF-0905',4),
 ('DOC057','ACF-0903',1),
 ('DOC057','ACF-0903',2),
 ('DOC057','ACF-0903',3),
 ('DOC057','ACF-0903',4),
 -- DOC058 María Magdalena Serrano Ortega · horario 08-12 · 1 materia(s)
 ('DOC058','SCD-1027',1),
 ('DOC058','SCD-1027',2),
 ('DOC058','SCD-1027',3),
 ('DOC058','SCD-1027',4),
 -- DOC059 Gabriela Lourdes Tapia Gonzalez · horario 08-12 · 4 materia(s)
 ('DOC059','SCD-1027',1),
 ('DOC059','SCD-1027',2),
 ('DOC059','SCD-1027',3),
 ('DOC059','SCD-1027',4),
 ('DOC059','SCA-1025',1),
 ('DOC059','SCA-1025',2),
 ('DOC059','SCA-1025',3),
 ('DOC059','SCA-1025',4),
 ('DOC059','SCB-1001',1),
 ('DOC059','SCB-1001',2),
 ('DOC059','SCB-1001',3),
 ('DOC059','SCB-1001',4),
 ('DOC059','ACA-0909',1),
 ('DOC059','ACA-0909',2),
 ('DOC059','ACA-0909',3),
 ('DOC059','ACA-0909',4),
 -- DOC060 Martha Patricia Ochoa Velardez · horario 08-12 · 1 materia(s)
 ('DOC060','SCC-1017',1),
 ('DOC060','SCC-1017',2),
 ('DOC060','SCC-1017',3),
 ('DOC060','SCC-1017',4),
 -- DOC061 Luis Maribel Guerrero · horario 08-10 · 1 materia(s)
 ('DOC061','SCC-1017',1),
 ('DOC061','SCC-1017',2),
 -- DOC062 Diana Lisseth Bravo Castro · horario 10-12 · 1 materia(s)
 ('DOC062','AEF-1031',3),
 ('DOC062','AEF-1031',4),
 -- DOC063 María Concepción Ibarra Gamiz · horario 08-12 · 1 materia(s)
 ('DOC063','SCD-1022',1),
 ('DOC063','SCD-1022',2),
 ('DOC063','SCD-1022',3),
 ('DOC063','SCD-1022',4),
 -- DOC064 Juan José Rogelio Orozco Garibay · horario 09-12 · 2 materia(s)
 ('DOC064','SCD-1022',2),
 ('DOC064','SCD-1022',3),
 ('DOC064','SCD-1022',4),
 ('DOC064','SCA-1025',2),
 ('DOC064','SCA-1025',3),
 ('DOC064','SCA-1025',4),
 -- DOC065 Miguel Angel López Ramirez · horario 08-11 · 1 materia(s)
 ('DOC065','SCD-1003',1),
 ('DOC065','SCD-1003',2),
 ('DOC065','SCD-1003',3),
 -- DOC066 Humberto Raiz Orozco · horario 08-11 · 1 materia(s)
 ('DOC066','SCC-1010',1),
 ('DOC066','SCC-1010',2),
 ('DOC066','SCC-1010',3),
 -- DOC067 Cynthia Peraza Ramirez · horario 08-12 · 1 materia(s)
 ('DOC067','SCC-1010',1),
 ('DOC067','SCC-1010',2),
 ('DOC067','SCC-1010',3),
 ('DOC067','SCC-1010',4),
 -- DOC068 Sergio Contreras Hernandez · horario 10-12 · 2 materia(s)
 ('DOC068','AEC-1034',3),
 ('DOC068','AEC-1034',4),
 ('DOC068','SCA-1002',3),
 ('DOC068','SCA-1002',4),
 -- DOC069 Christian Alonso Arenas Campis · horario 09-12 · 3 materia(s)
 ('DOC069','AEC-1034',2),
 ('DOC069','AEC-1034',3),
 ('DOC069','AEC-1034',4),
 ('DOC069','AEC-1061',2),
 ('DOC069','AEC-1061',3),
 ('DOC069','AEC-1061',4),
 ('DOC069','SCD-1021',2),
 ('DOC069','SCD-1021',3),
 ('DOC069','SCD-1021',4),
 -- DOC070 Erasmo Estrada Peña · horario 08-11 · 3 materia(s)
 ('DOC070','AEC-1061',1),
 ('DOC070','AEC-1061',2),
 ('DOC070','AEC-1061',3),
 ('DOC070','SCD-1015',1),
 ('DOC070','SCD-1015',2),
 ('DOC070','SCD-1015',3),
 ('DOC070','SCD-1016',1),
 ('DOC070','SCD-1016',2),
 ('DOC070','SCD-1016',3),
 -- DOC071 Rene Solis Reyes · horario 08-11 · 3 materia(s)
 ('DOC071','SCA-1025',1),
 ('DOC071','SCA-1025',2),
 ('DOC071','SCA-1025',3),
 ('DOC071','SCC-1014',1),
 ('DOC071','SCC-1014',2),
 ('DOC071','SCC-1014',3),
 ('DOC071','SCC-1023',1),
 ('DOC071','SCC-1023',2),
 ('DOC071','SCC-1023',3),
 -- DOC072 Reynaldo Andres Salas Carmona · horario 10-12 · 1 materia(s)
 ('DOC072','SCC-1007',3),
 ('DOC072','SCC-1007',4),
 -- DOC073 Daniel Alfredo Loreto Gomez · horario 10-12 · 1 materia(s)
 ('DOC073','ACD-0908',3),
 ('DOC073','ACD-0908',4),
 -- DOC074 Luis Alfonso Gaxiola Vega · horario 09-12 · 4 materia(s)
 ('DOC074','SCD-1015',2),
 ('DOC074','SCD-1015',3),
 ('DOC074','SCD-1015',4),
 ('DOC074','SCD-1016',2),
 ('DOC074','SCD-1016',3),
 ('DOC074','SCD-1016',4),
 ('DOC074','SCC-1019',2),
 ('DOC074','SCC-1019',3),
 ('DOC074','SCC-1019',4),
 ('DOC074','SCC-1023',2),
 ('DOC074','SCC-1023',3),
 ('DOC074','SCC-1023',4),
 -- DOC075 Jesus Ricardo Palma Valdez · horario 09-12 · 2 materia(s)
 ('DOC075','SCD-1021',2),
 ('DOC075','SCD-1021',3),
 ('DOC075','SCD-1021',4),
 ('DOC075','SCD-1004',2),
 ('DOC075','SCD-1004',3),
 ('DOC075','SCD-1004',4),
 -- DOC076 Fevrier Adolfo Valdez Acosta · horario 08-10 · 1 materia(s)
 ('DOC076','SCD-1021',1),
 ('DOC076','SCD-1021',2),
 -- DOC077 Rodrigo Leonardo Reyes Osorio · horario 08-12 · 2 materia(s)
 ('DOC077','SCA-1026',1),
 ('DOC077','SCA-1026',2),
 ('DOC077','SCA-1026',3),
 ('DOC077','SCA-1026',4),
 ('DOC077','SCG-1009',1),
 ('DOC077','SCG-1009',2),
 ('DOC077','SCG-1009',3),
 ('DOC077','SCG-1009',4),
 -- DOC078 Hector Javier Hinojosa Galván · horario 09-11 · 1 materia(s)
 ('DOC078','SCD-1011',2),
 ('DOC078','SCD-1011',3),
 -- DOC079 Daniela Adriana Sanchez Vizcarra · horario 08-11 · 1 materia(s)
 ('DOC079','ACA-0909',1),
 ('DOC079','ACA-0909',2),
 ('DOC079','ACA-0909',3),
 -- DOC080 Hector Alonso Miramontes Miramontes · horario 08-11 · 2 materia(s)
 ('DOC080','SCC-1023',1),
 ('DOC080','SCC-1023',2),
 ('DOC080','SCC-1023',3),
 ('DOC080','SCA-1002',1),
 ('DOC080','SCA-1002',2),
 ('DOC080','SCA-1002',3),
 -- DOC081 Octavio Romero Flores · horario 10-12 · 1 materia(s)
 ('DOC081','AEB-1055',3),
 ('DOC081','AEB-1055',4),
 -- DOC082 Jose Jonathan Perez Castro · horario 08-11 · 1 materia(s)
 ('DOC082','AEB-1055',1),
 ('DOC082','AEB-1055',2),
 ('DOC082','AEB-1055',3),
 -- DOC083 Ray Brunett Parra Galaviz · horario 08-12 · 1 materia(s)
 ('DOC083','AEB-1055',1),
 ('DOC083','AEB-1055',2),
 ('DOC083','AEB-1055',3),
 ('DOC083','AEB-1055',4),
 -- DOC084 Jose Mario García Valdez · horario 08-12 · 1 materia(s)
 ('DOC084','AEB-1055',1),
 ('DOC084','AEB-1055',2),
 ('DOC084','AEB-1055',3),
 ('DOC084','AEB-1055',4),
 -- DOC086 Bogart Yail Marquez Lobato · horario 08-12 · 1 materia(s)
 ('DOC086','ACA-0910',1),
 ('DOC086','ACA-0910',2),
 ('DOC086','ACA-0910',3),
 ('DOC086','ACA-0910',4),
 -- DOC087 Arnulfo Alanis Garza · horario 09-12 · 1 materia(s)
 ('DOC087','SCC-1002',2),
 ('DOC087','SCC-1002',3),
 ('DOC087','SCC-1002',4)
) v(Maestro, Materia, Bloque)
JOIN Periodo p  ON p.Clave = N'AGO-DIC 2026'
JOIN Maestro mt ON mt.Clave = v.Maestro
JOIN Materia ma ON ma.Clave = v.Materia;

EXEC sp_set_session_context @key = N'Origen', @value = NULL;
COMMIT TRANSACTION;
GO

/* ---------- VERIFICACION: cada fila debe coincidir con 'Esperado' ---------- */
SELECT 'Materias' AS Tabla, COUNT(*) AS Filas, 46 AS Esperado FROM Materia
UNION ALL SELECT 'Maestros',        COUNT(*), 85 FROM Maestro
UNION ALL SELECT 'Slots',           COUNT(*), 24 FROM PaqueteMateria
UNION ALL SELECT 'Disponibilidad',  COUNT(*), 450 FROM MaestroMateriaBloque;
GO