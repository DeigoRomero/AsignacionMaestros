/* ---------- CORRER ESTE SCRIPT UNA VEZ ESTÉ GENERADO EL ESQUEMA ---- */
USE AsignacionMaestros

/* ---------- BITACORA: historial de cada cambio en un slot ---------- */
CREATE TABLE BitacoraAsignacion (
    IdBitacora        BIGINT IDENTITY(1,1) NOT NULL,
    IdPaqueteMateria  INT         NOT NULL,
    IdMaestroAnterior INT         NULL,
    IdMaestroNuevo    INT         NULL,
    EstadoAnterior    VARCHAR(10) NOT NULL,
    EstadoNuevo       VARCHAR(10) NOT NULL,
    IdBloqueAnterior  TINYINT     NOT NULL,
    IdBloqueNuevo     TINYINT     NOT NULL,
    Origen            VARCHAR(30) NOT NULL,   -- Sistema | Manual | CambioDisponibilidad | ...
    Usuario           SYSNAME     NOT NULL CONSTRAINT DF_Bit_Usuario DEFAULT (SUSER_SNAME()),
    Fecha             DATETIME2(0) NOT NULL CONSTRAINT DF_Bit_Fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_BitacoraAsignacion PRIMARY KEY (IdBitacora),
    CONSTRAINT FK_Bit_Slot FOREIGN KEY (IdPaqueteMateria)
        REFERENCES PaqueteMateria (IdPaqueteMateria) ON DELETE CASCADE,
    CONSTRAINT FK_Bit_MaestroAnt FOREIGN KEY (IdMaestroAnterior) REFERENCES Maestro (IdMaestro),
    CONSTRAINT FK_Bit_MaestroNue FOREIGN KEY (IdMaestroNuevo)    REFERENCES Maestro (IdMaestro)
);
GO

/* ---------- TRIGGER: registra solo cuando algo realmente cambia ---------- */
-- El origen del cambio lo manda la aplicacion antes de operar:
--   EXEC sp_set_session_context @key = N'Origen', @value = N'Manual';
-- Si no lo manda, se guarda como 'Sistema'.
CREATE TRIGGER trg_PaqueteMateria_Bitacora
ON PaqueteMateria
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @origen VARCHAR(30) =
        ISNULL(CAST(SESSION_CONTEXT(N'Origen') AS VARCHAR(30)), 'Sistema');

    INSERT INTO BitacoraAsignacion
        (IdPaqueteMateria, IdMaestroAnterior, IdMaestroNuevo,
         EstadoAnterior, EstadoNuevo, IdBloqueAnterior, IdBloqueNuevo, Origen)
    SELECT i.IdPaqueteMateria, d.IdMaestro, i.IdMaestro,
           d.Estado, i.Estado, d.IdBloque, i.IdBloque, @origen
    FROM   inserted i
    JOIN   deleted  d ON d.IdPaqueteMateria = i.IdPaqueteMateria
    WHERE  ISNULL(i.IdMaestro, 0) <> ISNULL(d.IdMaestro, 0)
        OR i.Estado   <> d.Estado
        OR i.IdBloque <> d.IdBloque;
END;
GO

/* ---------- PROCEDIMIENTO: un maestro deja de ofrecer una materia/hora ---------- */
-- 1) Libera (deja Pendiente) los slots que tenia asignados en esa celda,
--    sean Asignado o Fijo, porque ya no serian validos.
-- 2) Borra la disponibilidad.
-- 3) Devuelve los slots liberados para que el servicio los reasigne.
-- @IdMateria = NULL quita todas las materias de ese maestro en ese bloque.
CREATE PROCEDURE sp_QuitarDisponibilidad
    @IdPeriodo INT,
    @IdMaestro INT,
    @IdBloque  TINYINT,
    @IdMateria INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @liberados TABLE (IdPaqueteMateria INT PRIMARY KEY);

    BEGIN TRANSACTION;

    EXEC sp_set_session_context @key = N'Origen', @value = N'CambioDisponibilidad';

    UPDATE PaqueteMateria
    SET    IdMaestro = NULL,
           Estado = 'Pendiente',
           MotivoPendiente = 'El maestro quito su disponibilidad'
    OUTPUT inserted.IdPaqueteMateria INTO @liberados (IdPaqueteMateria)
    WHERE  IdPeriodo = @IdPeriodo
      AND  IdMaestro = @IdMaestro
      AND  IdBloque  = @IdBloque
      AND  (@IdMateria IS NULL OR IdMateria = @IdMateria);

    DELETE FROM MaestroMateriaBloque
    WHERE  IdPeriodo = @IdPeriodo
      AND  IdMaestro = @IdMaestro
      AND  IdBloque  = @IdBloque
      AND  (@IdMateria IS NULL OR IdMateria = @IdMateria);

    EXEC sp_set_session_context @key = N'Origen', @value = NULL;

    COMMIT TRANSACTION;

    SELECT IdPaqueteMateria FROM @liberados;
END;
GO