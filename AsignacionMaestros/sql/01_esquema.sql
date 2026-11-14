/* =====================================================================
   Proyecto Final Base de datos - Asignacion de maestros a horarios
   Motor: SQL Server (T-SQL)
   Orden de ejecucion: 01_esquema.sql  ->  02_datos_ejemplo.sql
   ===================================================================== */

/* ---------- CATALOGOS ---------- */

CREATE TABLE Periodo (
    IdPeriodo  INT IDENTITY(1,1) NOT NULL,
    Clave      VARCHAR(20)  NOT NULL,            -- ej. 'A-D 01'
    Nombre     VARCHAR(100) NULL,
    CONSTRAINT PK_Periodo       PRIMARY KEY (IdPeriodo),
    CONSTRAINT UQ_Periodo_Clave UNIQUE (Clave)
);

CREATE TABLE Dia (
    IdDia   TINYINT     NOT NULL,                -- 1=lun ... 5=vie
    Nombre  VARCHAR(10) NOT NULL,
    CONSTRAINT PK_Dia        PRIMARY KEY (IdDia),
    CONSTRAINT UQ_Dia_Nombre UNIQUE (Nombre),
    CONSTRAINT CK_Dia_Rango  CHECK (IdDia BETWEEN 1 AND 7)
);

-- Dias en que hay clase en cada periodo (en el deck: lun-jue, viernes vacio)
CREATE TABLE PeriodoDia (
    IdPeriodo INT     NOT NULL,
    IdDia     TINYINT NOT NULL,
    CONSTRAINT PK_PeriodoDia PRIMARY KEY (IdPeriodo, IdDia),
    CONSTRAINT FK_PeriodoDia_Periodo FOREIGN KEY (IdPeriodo) REFERENCES Periodo (IdPeriodo),
    CONSTRAINT FK_PeriodoDia_Dia     FOREIGN KEY (IdDia)     REFERENCES Dia (IdDia)
);

-- Franjas de una hora. IdBloque tambien es el orden (1 = 08-09 ... 4 = 11-12)
CREATE TABLE Bloque (
    IdBloque   TINYINT NOT NULL,
    HoraInicio TIME(0) NOT NULL,
    HoraFin    TIME(0) NOT NULL,
    CONSTRAINT PK_Bloque        PRIMARY KEY (IdBloque),
    CONSTRAINT UQ_Bloque_Inicio UNIQUE (HoraInicio),
    CONSTRAINT CK_Bloque_Rango  CHECK (HoraFin > HoraInicio)
);

CREATE TABLE Materia (
    IdMateria INT IDENTITY(1,1) NOT NULL,
    Clave     VARCHAR(10)  NOT NULL,             -- ej. 'A'
    Nombre    VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Materia       PRIMARY KEY (IdMateria),
    CONSTRAINT UQ_Materia_Clave UNIQUE (Clave)
);

CREATE TABLE Maestro (
    IdMaestro INT IDENTITY(1,1) NOT NULL,
    Clave     VARCHAR(10)  NOT NULL,             -- ej. 'M001'
    Nombre    VARCHAR(100) NOT NULL,
    Activo    BIT          NOT NULL CONSTRAINT DF_Maestro_Activo DEFAULT (1),
    CONSTRAINT PK_Maestro       PRIMARY KEY (IdMaestro),
    CONSTRAINT UQ_Maestro_Clave UNIQUE (Clave)
);

/* ---------- ESTRUCTURA ACADEMICA ---------- */

-- Un paquete es un grado + grupo dentro de un periodo (1A, 1B, 1C, 2A, 2B, 3A)
CREATE TABLE Paquete (
    IdPaquete INT IDENTITY(1,1) NOT NULL,
    IdPeriodo INT     NOT NULL,
    Grado     TINYINT NOT NULL,
    Grupo     CHAR(1) NOT NULL,
    Clave AS (CAST(Grado AS VARCHAR(2)) + Grupo) PERSISTED,
    CONSTRAINT PK_Paquete         PRIMARY KEY (IdPaquete),
    CONSTRAINT UQ_Paquete_Natural UNIQUE (IdPeriodo, Grado, Grupo),
    CONSTRAINT UQ_Paquete_ConPer  UNIQUE (IdPaquete, IdPeriodo),   -- para la FK compuesta
    CONSTRAINT FK_Paquete_Periodo FOREIGN KEY (IdPeriodo) REFERENCES Periodo (IdPeriodo)
);

/* ---------- DISPONIBILIDAD DE MAESTROS ---------- */
-- Una fila = "este maestro ofrece esta materia en este bloque, en este periodo".
-- Es exactamente cada celda de las tablitas M001..M010 del deck.
CREATE TABLE MaestroMateriaBloque (
    IdPeriodo INT     NOT NULL,
    IdMaestro INT     NOT NULL,
    IdMateria INT     NOT NULL,
    IdBloque  TINYINT NOT NULL,
    CONSTRAINT PK_MaestroMateriaBloque PRIMARY KEY (IdPeriodo, IdMaestro, IdMateria, IdBloque),
    CONSTRAINT FK_MMB_Periodo FOREIGN KEY (IdPeriodo) REFERENCES Periodo (IdPeriodo),
    CONSTRAINT FK_MMB_Maestro FOREIGN KEY (IdMaestro) REFERENCES Maestro (IdMaestro),
    CONSTRAINT FK_MMB_Materia FOREIGN KEY (IdMateria) REFERENCES Materia (IdMateria),
    CONSTRAINT FK_MMB_Bloque  FOREIGN KEY (IdBloque)  REFERENCES Bloque (IdBloque)
);

/* ---------- HORARIO DE GRUPOS + ASIGNACION ---------- */
-- Una fila = un slot (paquete + materia + bloque). Es una fila de Horario_grupos.
-- IdMaestro NULL = pendiente (el "PEND" del deck).
CREATE TABLE PaqueteMateria (
    IdPaqueteMateria INT IDENTITY(1,1) NOT NULL,
    IdPaquete        INT     NOT NULL,
    IdPeriodo        INT     NOT NULL,
    IdMateria        INT     NOT NULL,
    IdBloque         TINYINT NOT NULL,
    IdMaestro        INT     NULL,
    Estado           VARCHAR(10)  NOT NULL CONSTRAINT DF_PM_Estado DEFAULT ('Pendiente'),
    MotivoPendiente  VARCHAR(200) NULL,
    CONSTRAINT PK_PaqueteMateria PRIMARY KEY (IdPaqueteMateria),

    -- Un paquete no puede tener dos materias a la misma hora, ni la misma materia dos veces
    CONSTRAINT UQ_PM_Paquete_Bloque  UNIQUE (IdPaquete, IdBloque),
    CONSTRAINT UQ_PM_Paquete_Materia UNIQUE (IdPaquete, IdMateria),

    CONSTRAINT FK_PM_Paquete FOREIGN KEY (IdPaquete, IdPeriodo) REFERENCES Paquete (IdPaquete, IdPeriodo),
    CONSTRAINT FK_PM_Materia FOREIGN KEY (IdMateria) REFERENCES Materia (IdMateria),
    CONSTRAINT FK_PM_Bloque  FOREIGN KEY (IdBloque)  REFERENCES Bloque (IdBloque),

    -- Regla (b): el maestro asignado debe ofrecer esa materia en ese bloque.
    -- Con IdMaestro NULL (pendiente) SQL Server no evalua esta FK.
    CONSTRAINT FK_PM_Disponibilidad FOREIGN KEY (IdPeriodo, IdMaestro, IdMateria, IdBloque)
        REFERENCES MaestroMateriaBloque (IdPeriodo, IdMaestro, IdMateria, IdBloque),

    CONSTRAINT CK_PM_Estado CHECK (Estado IN ('Pendiente', 'Asignado', 'Fijo')),
    -- Pendiente <=> sin maestro
    CONSTRAINT CK_PM_Coherencia CHECK (
        (Estado = 'Pendiente' AND IdMaestro IS NULL) OR
        (Estado <> 'Pendiente' AND IdMaestro IS NOT NULL)
    )
);

-- Regla (a): un maestro no puede estar en dos slots a la misma hora (mismo periodo).
-- Indice unico filtrado: ignora los pendientes (NULL).
CREATE UNIQUE INDEX UX_PM_Maestro_Bloque
    ON PaqueteMateria (IdPeriodo, IdMaestro, IdBloque)
    WHERE IdMaestro IS NOT NULL;
GO

/* ---------- VISTA: PASO 2 DEL ALGORITMO (CANDIDATOS) ---------- */
-- Para cada slot pendiente, los maestros que ofrecen esa materia a esa hora
-- y que no estan ocupados a esa hora por otra asignacion (Fijo o previa).
CREATE VIEW vw_Candidatos AS
SELECT pm.IdPaqueteMateria,
       pm.IdPeriodo,
       pm.IdBloque,
       mmb.IdMaestro
FROM   PaqueteMateria pm
JOIN   MaestroMateriaBloque mmb
       ON  mmb.IdPeriodo = pm.IdPeriodo
       AND mmb.IdMateria = pm.IdMateria
       AND mmb.IdBloque  = pm.IdBloque
JOIN   Maestro m ON m.IdMaestro = mmb.IdMaestro AND m.Activo = 1
WHERE  pm.Estado = 'Pendiente'
  AND NOT EXISTS (
        SELECT 1
        FROM   PaqueteMateria ocupado
        WHERE  ocupado.IdPeriodo = pm.IdPeriodo
          AND  ocupado.IdBloque  = pm.IdBloque
          AND  ocupado.IdMaestro = mmb.IdMaestro
      );
GO
