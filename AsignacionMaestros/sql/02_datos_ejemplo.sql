/* Datos de ejemplo tomados del deck (periodo A-D 01).
   Prueba de aceptacion: el algoritmo debe dar 19 asignados y 5 pendientes
   (por hora: 08-09 -> 2, 09-10 -> 0, 10-11 -> 1, 11-12 -> 2). */

INSERT INTO Periodo (Clave, Nombre) VALUES ('A-D 01', 'Periodo de ejemplo A-D 01');

INSERT INTO Dia (IdDia, Nombre) VALUES (1,'Lunes'),(2,'Martes'),(3,'Miercoles'),(4,'Jueves'),(5,'Viernes');
INSERT INTO PeriodoDia (IdPeriodo, IdDia)
SELECT p.IdPeriodo, d.IdDia FROM Periodo p CROSS JOIN Dia d WHERE p.Clave='A-D 01' AND d.IdDia BETWEEN 1 AND 4;

INSERT INTO Bloque (IdBloque, HoraInicio, HoraFin) VALUES
 (1,'08:00','09:00'),(2,'09:00','10:00'),(3,'10:00','11:00'),(4,'11:00','12:00');

INSERT INTO Materia (Clave, Nombre) VALUES
 ('A','Materia A'),
 ('B','Materia B'),
 ('C','Materia C'),
 ('D','Materia D'),
 ('E','Materia E'),
 ('F','Materia F'),
 ('G','Materia G'),
 ('H','Materia H'),
 ('I','Materia I'),
 ('J','Materia J'),
 ('K','Materia K'),
 ('L','Materia L');

INSERT INTO Maestro (Clave, Nombre) VALUES
 ('M001','Maestro M001'),
 ('M002','Maestro M002'),
 ('M003','Maestro M003'),
 ('M004','Maestro M004'),
 ('M005','Maestro M005'),
 ('M006','Maestro M006'),
 ('M007','Maestro M007'),
 ('M008','Maestro M008'),
 ('M009','Maestro M009'),
 ('M010','Maestro M010');

INSERT INTO Paquete (IdPeriodo, Grado, Grupo)
SELECT p.IdPeriodo, v.Grado, v.Grupo
FROM Periodo p CROSS JOIN (VALUES (1,'A'),(1,'B'),(1,'C'),(2,'A'),(2,'B'),(3,'A')) v(Grado, Grupo)
WHERE p.Clave='A-D 01';

INSERT INTO PaqueteMateria (IdPaquete, IdPeriodo, IdMateria, IdBloque)
SELECT pa.IdPaquete, pa.IdPeriodo, ma.IdMateria, v.Bloque
FROM (VALUES
 ('1A','A',1),
 ('1A','C',2),
 ('1A','F',3),
 ('1A','J',4),
 ('1B','C',1),
 ('1B','F',2),
 ('1B','J',3),
 ('1B','A',4),
 ('1C','F',1),
 ('1C','J',2),
 ('1C','A',3),
 ('1C','C',4),
 ('2A','B',1),
 ('2A','D',2),
 ('2A','G',3),
 ('2A','H',4),
 ('2B','G',1),
 ('2B','H',2),
 ('2B','B',3),
 ('2B','D',4),
 ('3A','E',1),
 ('3A','K',2),
 ('3A','L',3),
 ('3A','I',4)
) v(Paquete, Materia, Bloque)
JOIN Periodo p  ON p.Clave = 'A-D 01'
JOIN Paquete pa ON pa.IdPeriodo = p.IdPeriodo AND pa.Clave = v.Paquete
JOIN Materia ma ON ma.Clave = v.Materia;

INSERT INTO MaestroMateriaBloque (IdPeriodo, IdMaestro, IdMateria, IdBloque)
SELECT p.IdPeriodo, mt.IdMaestro, ma.IdMateria, v.Bloque
FROM (VALUES
 ('M001','A',1),
 ('M001','A',2),
 ('M001','A',3),
 ('M001','A',4),
 ('M001','B',1),
 ('M001','B',2),
 ('M001','B',3),
 ('M001','B',4),
 ('M001','E',1),
 ('M001','E',2),
 ('M001','E',3),
 ('M001','E',4),
 ('M002','C',2),
 ('M002','C',3),
 ('M002','C',4),
 ('M002','D',2),
 ('M002','D',3),
 ('M002','D',4),
 ('M002','K',2),
 ('M002','K',3),
 ('M002','K',4),
 ('M002','L',2),
 ('M002','L',3),
 ('M002','L',4),
 ('M003','H',1),
 ('M003','H',3),
 ('M003','I',1),
 ('M003','I',3),
 ('M004','F',1),
 ('M004','F',2),
 ('M004','G',1),
 ('M004','G',2),
 ('M005','B',1),
 ('M005','B',2),
 ('M005','B',3),
 ('M005','B',4),
 ('M005','E',1),
 ('M005','E',2),
 ('M005','E',3),
 ('M005','E',4),
 ('M006','F',3),
 ('M006','F',4),
 ('M006','G',3),
 ('M006','G',4),
 ('M007','K',1),
 ('M007','K',2),
 ('M007','K',3),
 ('M007','L',1),
 ('M007','L',2),
 ('M007','L',3),
 ('M008','J',1),
 ('M008','J',2),
 ('M009','A',1),
 ('M009','A',2),
 ('M009','A',3),
 ('M009','A',4),
 ('M009','C',1),
 ('M009','C',2),
 ('M009','C',3),
 ('M009','C',4),
 ('M009','D',1),
 ('M009','D',2),
 ('M009','D',3),
 ('M009','D',4),
 ('M010','H',1),
 ('M010','H',2),
 ('M010','H',3),
 ('M010','H',4),
 ('M010','I',1),
 ('M010','I',2),
 ('M010','I',3),
 ('M010','I',4),
 ('M010','J',1),
 ('M010','J',2),
 ('M010','J',3),
 ('M010','J',4)
) v(Maestro, Materia, Bloque)
JOIN Periodo p  ON p.Clave = 'A-D 01'
JOIN Maestro mt ON mt.Clave = v.Maestro
JOIN Materia ma ON ma.Clave = v.Materia;
