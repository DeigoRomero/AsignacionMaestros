namespace AsignacionMaestros.Core;

public enum EstadoSlot { Pendiente, Asignado, Fijo }

public enum ModoAsignacion
{
    /// <summary>No toca lo ya asignado; solo procesa los pendientes.</summary>
    Conservador,
    /// <summary>Recalcula todo lo que no sea Fijo (conservando maestros actuales cuando se puede).</summary>
    Reoptimizar
}

/// <summary>Una fila de Horario_grupos: paquete + materia + bloque (hora).</summary>
public sealed class Slot
{
    public int Id { get; init; }
    public string Paquete { get; init; } = "";      // ej. "1A"
    public int IdMateria { get; init; }
    public string Materia { get; init; } = "";      // ej. "A"
    public int Bloque { get; init; }                // 1..4 (= IdBloque en la BD)
    public string Hora { get; init; } = "";         // etiqueta para mostrar, ej. "08-09"
    public int? IdMaestro { get; set; }             // null = pendiente
    public EstadoSlot Estado { get; set; } = EstadoSlot.Pendiente;
    public string? Motivo { get; set; }             // por qué quedó pendiente

    public Slot Clonar() => (Slot)MemberwiseClone();
    public string Etiqueta => $"{Paquete} · {Materia} · {(Hora == "" ? "bloque " + Bloque : Hora)}";
}

public sealed class Maestro
{
    public int Id { get; init; }
    public string Clave { get; init; } = "";        // ej. "M001"
    public string Nombre { get; init; } = "";
    /// <summary>Celdas (materia, bloque) que el maestro ofrece.</summary>
    public HashSet<(int IdMateria, int Bloque)> Ofrece { get; init; } = new();

    public bool Ofrecer(int idMateria, int bloque) => Ofrece.Contains((idMateria, bloque));

    public Maestro ConOferta(HashSet<(int IdMateria, int Bloque)> nueva) =>
        new() { Id = Id, Clave = Clave, Nombre = Nombre, Ofrece = nueva };
}

public sealed record CambioPropuesto(
    int IdSlot,
    int? MaestroAnterior, int? MaestroNuevo,
    EstadoSlot EstadoAnterior, EstadoSlot EstadoNuevo,
    string? MotivoNuevo)
{
    public bool CambiaMaestro => MaestroAnterior != MaestroNuevo;
}

public sealed class ResultadoAsignacion
{
    public required IReadOnlyList<Slot> Slots { get; init; }
    public required IReadOnlyList<CambioPropuesto> Cambios { get; init; }
    public int Asignados => Slots.Count(s => s.Estado != EstadoSlot.Pendiente);
    public int Pendientes => Slots.Count(s => s.Estado == EstadoSlot.Pendiente);
}
