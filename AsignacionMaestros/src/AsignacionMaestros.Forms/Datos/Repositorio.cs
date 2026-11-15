using AsignacionMaestros.Core;
using Microsoft.Data.SqlClient;

namespace AsignacionMaestros.Forms.Datos;

public sealed record PeriodoItem(int Id, string Clave)
{
    public override string ToString() => Clave;   // lo que muestra el ComboBox
}

public sealed record MateriaItem(int Id, string Clave, string Nombre);
public sealed record BloqueItem(int Id, string Etiqueta);   // ej. (1, "08-09")

/// <summary>Único lugar que habla con SQL Server. El resto de la app usa solo el Core.</summary>
public sealed class Repositorio
{
    private readonly string _cadena;
    public Repositorio(string cadena) => _cadena = cadena;

    private SqlConnection Abrir()
    {
        var cn = new SqlConnection(_cadena);
        cn.Open();
        return cn;
    }

    public List<PeriodoItem> Periodos()
    {
        using var cn = Abrir();
        using var cmd = new SqlCommand("SELECT IdPeriodo, Clave FROM Periodo ORDER BY IdPeriodo", cn);
        using var rd = cmd.ExecuteReader();
        var lista = new List<PeriodoItem>();
        while (rd.Read()) lista.Add(new PeriodoItem(rd.GetInt32(0), rd.GetString(1)));
        return lista;
    }

    public List<MateriaItem> CargarMaterias()
    {
        using var cn = Abrir();
        using var cmd = new SqlCommand("SELECT IdMateria, Clave, Nombre FROM Materia ORDER BY Clave", cn);
        using var rd = cmd.ExecuteReader();
        var lista = new List<MateriaItem>();
        while (rd.Read()) lista.Add(new MateriaItem(rd.GetInt32(0), rd.GetString(1), rd.GetString(2)));
        return lista;
    }

    public List<BloqueItem> CargarBloques()
    {
        const string sql = @"
SELECT IdBloque,
       LEFT(CONVERT(varchar(8), HoraInicio, 108), 2) + '-' + LEFT(CONVERT(varchar(8), HoraFin, 108), 2)
FROM   Bloque ORDER BY IdBloque";
        using var cn = Abrir();
        using var cmd = new SqlCommand(sql, cn);
        using var rd = cmd.ExecuteReader();
        var lista = new List<BloqueItem>();
        while (rd.Read()) lista.Add(new BloqueItem(rd.GetByte(0), rd.GetString(1)));   // TINYINT -> byte
        return lista;
    }

    public List<Slot> CargarSlots(int idPeriodo)
    {
        const string sql = @"
SELECT pm.IdPaqueteMateria, p.Clave, ma.IdMateria, ma.Nombre, pm.IdBloque,
       LEFT(CONVERT(varchar(8), b.HoraInicio, 108), 2) + '-' + LEFT(CONVERT(varchar(8), b.HoraFin, 108), 2),
       pm.IdMaestro, pm.Estado, pm.MotivoPendiente
FROM   PaqueteMateria pm
JOIN   Paquete p  ON p.IdPaquete  = pm.IdPaquete
JOIN   Materia ma ON ma.IdMateria = pm.IdMateria
JOIN   Bloque  b  ON b.IdBloque   = pm.IdBloque
WHERE  pm.IdPeriodo = @per
ORDER  BY p.Grado, p.Grupo, pm.IdBloque";

        using var cn = Abrir();
        using var cmd = new SqlCommand(sql, cn);
        cmd.Parameters.AddWithValue("@per", idPeriodo);
        using var rd = cmd.ExecuteReader();
        var lista = new List<Slot>();
        while (rd.Read())
            lista.Add(new Slot
            {
                Id = rd.GetInt32(0),
                Paquete = rd.GetString(1),
                IdMateria = rd.GetInt32(2),
                Materia = rd.GetString(3),
                Bloque = rd.GetByte(4),                       // TINYINT -> byte
                Hora = rd.GetString(5),
                IdMaestro = rd.IsDBNull(6) ? null : rd.GetInt32(6),
                Estado = Enum.Parse<EstadoSlot>(rd.GetString(7)),
                Motivo = rd.IsDBNull(8) ? null : rd.GetString(8),
            });
        return lista;
    }

    public List<Maestro> CargarMaestros(int idPeriodo)
    {
        using var cn = Abrir();
        var porId = new Dictionary<int, Maestro>();

        using (var cmd = new SqlCommand("SELECT IdMaestro, Clave, Nombre FROM Maestro WHERE Activo = 1 ORDER BY Clave", cn))
        using (var rd = cmd.ExecuteReader())
            while (rd.Read())
                porId[rd.GetInt32(0)] = new Maestro { Id = rd.GetInt32(0), Clave = rd.GetString(1), Nombre = rd.GetString(2) };

        using (var cmd = new SqlCommand(
            "SELECT IdMaestro, IdMateria, IdBloque FROM MaestroMateriaBloque WHERE IdPeriodo = @per", cn))
        {
            cmd.Parameters.AddWithValue("@per", idPeriodo);
            using var rd = cmd.ExecuteReader();
            while (rd.Read())
                if (porId.TryGetValue(rd.GetInt32(0), out var m))
                    m.Ofrece.Add((rd.GetInt32(1), rd.GetByte(2)));
        }
        return porId.Values.ToList();
    }

    /// <summary>
    /// Guarda solo lo que cambió, en una transacción. En dos fases: primero se sueltan los maestros
    /// de los slots que se mueven y luego se asignan los nuevos; así el índice único
    /// (maestro, hora) nunca choca mientras se reacomoda (por ejemplo, en un intercambio).
    /// </summary>
    public void GuardarCambios(IEnumerable<CambioPropuesto> cambios, string origen)
    {
        var lista = cambios.ToList();
        if (lista.Count == 0) return;

        using var cn = Abrir();
        using var tx = cn.BeginTransaction();

        Ejecutar(cn, tx, "EXEC sp_set_session_context @key = N'Origen', @value = @o", ("@o", origen));

        foreach (var c in lista.Where(c => c.CambiaMaestro && c.MaestroAnterior != null))
            Ejecutar(cn, tx,
                "UPDATE PaqueteMateria SET IdMaestro = NULL, Estado = 'Pendiente' WHERE IdPaqueteMateria = @id",
                ("@id", c.IdSlot));

        foreach (var c in lista)
            Ejecutar(cn, tx,
                "UPDATE PaqueteMateria SET IdMaestro = @m, Estado = @e, MotivoPendiente = @mot WHERE IdPaqueteMateria = @id",
                ("@m", c.MaestroNuevo), ("@e", c.EstadoNuevo.ToString()), ("@mot", c.MotivoNuevo), ("@id", c.IdSlot));

        tx.Commit();
    }

    /// <summary>
    /// Quita todos los maestros de los slots del periodo (también los Fijo) y los deja Pendiente.
    /// Si se pide, borra además la disponibilidad (materia + hora que ofrece cada maestro).
    /// Primero va lo de los slots: la llave foránea no deja borrar disponibilidad mientras alguien la use.
    /// </summary>
    public (int Asignaciones, int Disponibilidad) LimpiarPeriodo(int idPeriodo, bool incluirDisponibilidad)
    {
        using var cn = Abrir();
        using var tx = cn.BeginTransaction();

        Ejecutar(cn, tx, "EXEC sp_set_session_context @key = N'Origen', @value = N'Limpieza'");

        int asignaciones;
        using (var cmd = new SqlCommand(@"
UPDATE PaqueteMateria
SET    IdMaestro = NULL, Estado = 'Pendiente', MotivoPendiente = NULL
WHERE  IdPeriodo = @per AND (IdMaestro IS NOT NULL OR MotivoPendiente IS NOT NULL)", cn, tx))
        {
            cmd.Parameters.AddWithValue("@per", idPeriodo);
            asignaciones = cmd.ExecuteNonQuery();
        }

        var disponibilidad = 0;
        if (incluirDisponibilidad)
            using (var cmd = new SqlCommand("DELETE FROM MaestroMateriaBloque WHERE IdPeriodo = @per", cn, tx))
            {
                cmd.Parameters.AddWithValue("@per", idPeriodo);
                disponibilidad = cmd.ExecuteNonQuery();
            }

        tx.Commit();
        return (asignaciones, disponibilidad);
    }

    private static void Ejecutar(SqlConnection cn, SqlTransaction tx, string sql, params (string Nombre, object? Valor)[] ps)
    {
        using var cmd = new SqlCommand(sql, cn, tx);
        foreach (var (nombre, valor) in ps)
            cmd.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);
        cmd.ExecuteNonQuery();
    }
}
