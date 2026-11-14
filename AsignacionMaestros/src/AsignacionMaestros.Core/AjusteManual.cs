namespace AsignacionMaestros.Core;

public enum TipoOpcion
{
    /// <summary>El maestro está libre a esa hora: se asigna directo.</summary>
    Libre,
    /// <summary>Ocupado en otro slot de esa hora; ambos se cambian de lugar (los dos pueden dar la materia del otro).</summary>
    Intercambio,
    /// <summary>Ocupado en otro slot de esa hora; ese otro slot queda pendiente.</summary>
    Reemplazo
}

public sealed record OpcionManual(TipoOpcion Tipo, int IdMaestro, int? IdSlotAfectado, string Descripcion);

/// <summary>Cambios hechos a mano por el coordinador. Lo que se decide aquí queda como Fijo.</summary>
public static class AjusteManual
{
    public static List<OpcionManual> Opciones(
        IReadOnlyList<Slot> slots, IReadOnlyList<Maestro> maestros, int idSlot)
    {
        var s = slots.First(x => x.Id == idSlot);
        var actual = s.IdMaestro is int id ? maestros.FirstOrDefault(m => m.Id == id) : null;
        var opciones = new List<OpcionManual>();

        foreach (var m in maestros.Where(m => m.Id != s.IdMaestro && m.Ofrecer(s.IdMateria, s.Bloque))
                                  .OrderBy(m => m.Clave, StringComparer.Ordinal))
        {
            var x = slots.FirstOrDefault(o => o.Bloque == s.Bloque && o.IdMaestro == m.Id);

            if (x == null)
            {
                opciones.Add(new(TipoOpcion.Libre, m.Id, null, $"{m.Clave} está libre a esa hora."));
                continue;
            }
            if (x.Estado == EstadoSlot.Fijo) continue;   // lo fijo no se toca

            if (actual != null && actual.Ofrecer(x.IdMateria, x.Bloque))
                opciones.Add(new(TipoOpcion.Intercambio, m.Id, x.Id,
                    $"Intercambiar: {m.Clave} pasa aquí y {actual.Clave} pasa a {x.Etiqueta}."));

            opciones.Add(new(TipoOpcion.Reemplazo, m.Id, x.Id,
                $"Quitar a {m.Clave} de {x.Etiqueta} (ese slot queda pendiente)."));
        }
        return opciones;
    }

    public static ResultadoAsignacion Aplicar(IReadOnlyList<Slot> original, int idSlot, OpcionManual op)
    {
        var slots = original.Select(x => x.Clonar()).ToList();
        var s = slots.First(x => x.Id == idSlot);
        var maestroAnterior = s.IdMaestro;
        var x = op.IdSlotAfectado is int ix ? slots.First(o => o.Id == ix) : null;

        s.IdMaestro = op.IdMaestro;
        s.Estado = EstadoSlot.Fijo;
        s.Motivo = null;

        if (x != null && op.Tipo == TipoOpcion.Intercambio)
        {
            x.IdMaestro = maestroAnterior;
            x.Estado = EstadoSlot.Fijo;
            x.Motivo = null;
        }
        else if (x != null && op.Tipo == TipoOpcion.Reemplazo)
        {
            x.IdMaestro = null;
            x.Estado = EstadoSlot.Pendiente;
            x.Motivo = "Su maestro fue reasignado a mano a otro slot de esa hora.";
        }
        return Asignador.ArmarResultado(original, slots);
    }

    /// <summary>El coordinador quita al maestro de un slot y lo deja pendiente.</summary>
    public static ResultadoAsignacion Quitar(IReadOnlyList<Slot> original, int idSlot)
    {
        var slots = original.Select(x => x.Clonar()).ToList();
        var s = slots.First(x => x.Id == idSlot);
        s.IdMaestro = null;
        s.Estado = EstadoSlot.Pendiente;
        s.Motivo = "Se quitó el maestro a mano.";
        return Asignador.ArmarResultado(original, slots);
    }
}
