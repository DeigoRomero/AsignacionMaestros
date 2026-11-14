using AsignacionMaestros.Core;

// ---------- Datos del deck (periodo A-D 01) ----------
const string Materias = "ABCDEFGHIJKL";
int IdMat(char c) => Materias.IndexOf(c) + 1;

var demanda = new (string Paquete, string Materias)[]
{
    ("1A", "ACFJ"), ("1B", "CFJA"), ("1C", "FJAC"),
    ("2A", "BDGH"), ("2B", "GHBD"), ("3A", "EKLI"),
};

var slots = new List<Slot>();
foreach (var (paquete, ms) in demanda)
    for (int h = 0; h < 4; h++)
        slots.Add(new Slot
        {
            Id = slots.Count + 1, Paquete = paquete, IdMateria = IdMat(ms[h]), Materia = ms[h].ToString(),
            Bloque = h + 1, Hora = $"{8 + h:00}-{9 + h:00}",
        });

// (clave, materias, bloques)
Maestro M(int id, string materias, params int[] bloques) => new()
{
    Id = id, Clave = $"M{id:000}", Nombre = $"Maestro M{id:000}",
    Ofrece = materias.SelectMany(c => bloques.Select(b => (IdMat(c), b))).ToHashSet(),
};
var maestros = new List<Maestro>
{
    M(1, "ABE", 1, 2, 3, 4),
    M(2, "CDKL", 2, 3, 4),
    M(3, "HI", 1, 3),
    M(4, "FG", 1, 2),
    M(5, "BE", 1, 2, 3, 4),
    M(6, "GF", 3, 4),
    M(7, "LK", 1, 2, 3),
    M(8, "J", 1, 2),
    M(9, "ACD", 1, 2, 3, 4),
    M(10, "HIJ", 1, 2, 3, 4),
};

// ---------- Mini arnés de pruebas ----------
int fallos = 0;
void Prueba(string nombre, bool ok, string detalle = "")
{
    Console.WriteLine($"{(ok ? "PASS" : "FAIL")}  {nombre}{(ok || detalle == "" ? "" : "  -> " + detalle)}");
    if (!ok) fallos++;
}

// 1) Prueba de aceptación: 19 asignados, 5 pendientes, 2/0/1/2 por hora
var r1 = Asignador.Asignar(slots, maestros, ModoAsignacion.Reoptimizar);
Prueba("Deck: 19 asignados y 5 pendientes", r1.Asignados == 19 && r1.Pendientes == 5, $"{r1.Asignados}/{r1.Pendientes}");
var pendPorHora = Enumerable.Range(1, 4).Select(b => r1.Slots.Count(s => s.Bloque == b && s.Estado == EstadoSlot.Pendiente)).ToArray();
Prueba("Deck: pendientes por hora 2,0,1,2", pendPorHora.SequenceEqual(new[] { 2, 0, 1, 2 }), string.Join(",", pendPorHora));
var err1 = Asignador.Validar(r1.Slots, maestros);
Prueba("Deck: sin doble reserva ni maestro inválido", err1.Count == 0, string.Join(" | ", err1));
Prueba("Deck: todo pendiente trae motivo", r1.Slots.Where(s => s.Estado == EstadoSlot.Pendiente).All(s => !string.IsNullOrWhiteSpace(s.Motivo)));

// 2) Determinismo y estabilidad
var r1b = Asignador.Asignar(slots, maestros, ModoAsignacion.Reoptimizar);
Prueba("Determinista: dos corridas dan lo mismo", r1.Slots.Zip(r1b.Slots).All(p => p.First.IdMaestro == p.Second.IdMaestro));
var r2 = Asignador.Asignar(r1.Slots, maestros, ModoAsignacion.Reoptimizar);
Prueba("Estable: reoptimizar lo ya asignado no mueve a nadie", !r2.Cambios.Any(c => c.CambiaMaestro), $"{r2.Cambios.Count(c => c.CambiaMaestro)} cambios");
var r2c = Asignador.Asignar(r1.Slots, maestros, ModoAsignacion.Conservador);
Prueba("Conservador sobre lo ya asignado: sin cambios", r2c.Cambios.Count == 0);

// 3) Fijo se respeta
var conFijo = r1.Slots.Select(s => s.Clonar()).ToList();
var slotG = conFijo.First(s => s.Paquete == "2A" && s.Materia == "G");      // pendiente (10-11)
var m006 = maestros.First(m => m.Clave == "M006");
slotG.IdMaestro = m006.Id; slotG.Estado = EstadoSlot.Fijo; slotG.Motivo = null;
var f1A = conFijo.First(s => s.Paquete == "1A" && s.Materia == "F");        // tenía a M006 a la misma hora
f1A.IdMaestro = null; f1A.Estado = EstadoSlot.Pendiente;
var r3 = Asignador.Asignar(conFijo, maestros, ModoAsignacion.Reoptimizar);
var g3 = r3.Slots.First(s => s.Id == slotG.Id);
Prueba("Fijo: se conserva tras reoptimizar", g3.Estado == EstadoSlot.Fijo && g3.IdMaestro == m006.Id);
Prueba("Fijo: el resultado sigue siendo válido", Asignador.Validar(r3.Slots, maestros).Count == 0);

// 4) Flujo "el maestro cambia lo que ofrece": M010 deja de ofrecer J a las 11-12
var m010 = maestros.First(m => m.Clave == "M010");
var nuevaOferta = m010.Ofrece.Where(c => !(c.IdMateria == IdMat('J') && c.Bloque == 4)).ToHashSet();
var maestros2 = maestros.Select(m => m.Id == m010.Id ? m.ConOferta(nuevaOferta) : m).ToList();
var afectados = Asignador.SlotsAfectados(r1.Slots, m010.Id, nuevaOferta);
Prueba("Cambio de oferta: detecta 1 slot afectado (1A·J·11-12)", afectados.Count == 1 && afectados[0].Paquete == "1A" && afectados[0].Materia == "J");
var r4 = Asignador.ReasignarPorCambioDeOferta(r1.Slots, maestros2, m010.Id);
Prueba("Cambio de oferta: resultado válido", Asignador.Validar(r4.Slots, maestros2).Count == 0, string.Join(" | ", Asignador.Validar(r4.Slots, maestros2)));
var cambiosFuera = r4.Cambios.Where(c => r1.Slots.First(s => s.Id == c.IdSlot).Bloque != 4).ToList();
Prueba("Cambio de oferta: no toca nada fuera de las 11-12", cambiosFuera.Count == 0);
var j1A = r4.Slots.First(s => s.Paquete == "1A" && s.Materia == "J");
Prueba("Cambio de oferta: 1A·J queda pendiente con motivo claro", j1A.Estado == EstadoSlot.Pendiente && j1A.Motivo!.Contains("Ningún maestro ofrece"), j1A.Motivo ?? "");
Prueba("Cambio de oferta: total de pendientes sigue en 5", r4.Pendientes == 5, r4.Pendientes.ToString());

// 5) Cambios manuales: toda opción ofrecida debe dejar el horario válido
int opcionesProbadas = 0; bool todasValidas = true; var tipos = new HashSet<TipoOpcion>();
foreach (var s in r1.Slots)
    foreach (var op in AjusteManual.Opciones(r1.Slots, maestros, s.Id))
    {
        opcionesProbadas++; tipos.Add(op.Tipo);
        var res = AjusteManual.Aplicar(r1.Slots, s.Id, op);
        var e = Asignador.Validar(res.Slots, maestros);
        if (e.Count > 0) { todasValidas = false; Console.WriteLine("   " + s.Etiqueta + " / " + op.Descripcion + " -> " + string.Join(" | ", e)); }
    }
Prueba($"Manual: las {opcionesProbadas} opciones generadas dejan el horario válido", todasValidas && opcionesProbadas > 0);
Prueba("Manual: aparecen los 3 tipos (Libre, Intercambio, Reemplazo)", tipos.Count == 3, string.Join(",", tipos));


// 6) Quitar maestro a mano
{
    var slotAsignado = r1.Slots.First(s => s.Estado == EstadoSlot.Asignado);
    var rq = AjusteManual.Quitar(r1.Slots, slotAsignado.Id);
    var despues = rq.Slots.First(s => s.Id == slotAsignado.Id);
    Prueba("Quitar: el slot queda pendiente sin maestro", despues.Estado == EstadoSlot.Pendiente && despues.IdMaestro == null);
    Prueba("Quitar: resultado válido y un solo cambio", Asignador.Validar(rq.Slots, maestros).Count == 0 && rq.Cambios.Count == 1 && rq.Cambios[0].CambiaMaestro);
}

// 7) Los motivos nunca exceden la columna (200), aunque los nombres de materia sean larguísimos
{
    var largos = slots.Select(s => new Slot { Id = s.Id, Paquete = s.Paquete, IdMateria = s.IdMateria,
        Materia = new string('x', 70) + s.Materia, Bloque = s.Bloque, Hora = s.Hora }).ToList();
    var rl = Asignador.Asignar(largos, maestros, ModoAsignacion.Reoptimizar);
    var motivos = rl.Slots.Where(s => s.Estado == EstadoSlot.Pendiente).Select(s => s.Motivo ?? "").ToList();
    Prueba("Motivos largos se recortan a 200 caracteres", motivos.Count == 5 && motivos.All(m => m.Length > 0 && m.Length <= 200), string.Join(",", motivos.Select(m => m.Length)));
}

Console.WriteLine(fallos == 0 ? "\nTODO BIEN" : $"\n{fallos} PRUEBA(S) FALLARON");
return fallos == 0 ? 0 : 1;
