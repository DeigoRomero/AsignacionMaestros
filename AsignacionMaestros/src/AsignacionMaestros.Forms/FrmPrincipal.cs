/* Mensaje de Diego:
 * Esta es la pantalla principal y todo el diseño de la interfaz está aquí. 
 * No hay nada más que tocar en el resto del proyecto, 
 * salvo que quieras cambiar la base de datos [algún valiente que quiera poner todos los nombres de profesores reales] o la lógica de asignación.
*/
using AsignacionMaestros.Core;
using AsignacionMaestros.Forms.Datos;

namespace AsignacionMaestros.Forms;

public sealed class FrmPrincipal : Form
{
    private readonly Repositorio _repo;

    private readonly ComboBox _cmbPeriodo = new() { DropDownStyle = ComboBoxStyle.DropDownList, Width = 160 };
    private readonly Button _btnAsignar = new() { Text = "Asignar pendientes", AutoSize = true };
    private readonly Button _btnReoptimizar = new() { Text = "Reoptimizar todo", AutoSize = true };
    private readonly Button _btnCambiar = new() { Text = "Cambiar maestro…", AutoSize = true, Enabled = false, Margin = new Padding(24, 3, 3, 3) };   // NUEVO
    private readonly Button _btnDisponibilidad = new() { Text = "Disponibilidad…", AutoSize = true };   // NUEVO
    private readonly Button _btnLimpiar = new() { Text = "Limpiar horarios", AutoSize = true, Margin = new Padding(24, 3, 3, 3) };
    private readonly Button _btnRecargar = new() { Text = "Recargar", AutoSize = true };
    private readonly ToolStripStatusLabel _lblEstado = new();
    private readonly DataGridView _grid = new()
    {
        Dock = DockStyle.Fill, ReadOnly = true, AllowUserToAddRows = false, AllowUserToDeleteRows = false,
        RowHeadersVisible = false, SelectionMode = DataGridViewSelectionMode.FullRowSelect, MultiSelect = false,
        AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
    };
    // Datos cargados de la base de datos (IMPORTANTE HABER CORRIDO LOS 3 SCRIPTS ANTES DE EJECUTAR)
    private List<Slot> _slots = new();
    private List<Maestro> _maestros = new();
    private bool _cargando;

    public FrmPrincipal(Repositorio repo)
    {
        // Se inyecta el repositorio de datos para que la pantalla pueda cargar y guardar información
        _repo = repo;
        Text = "Asignación de maestros";
        Size = new Size(1000, 640);
        StartPosition = FormStartPosition.CenterScreen;

        // Se crean las columnas de la tabla
        foreach (var titulo in new[] { "Paquete", "Materia", "Hora", "Maestro", "Estado", "Motivo" })
            _grid.Columns.Add(titulo, titulo);
        _grid.Columns["Motivo"]!.FillWeight = 300;

        var panel = new FlowLayoutPanel { Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(8) };
        panel.Controls.Add(new Label { Text = "Periodo:", AutoSize = true, Margin = new Padding(0, 8, 4, 0) });
        panel.Controls.Add(_cmbPeriodo);
        panel.Controls.Add(_btnAsignar);
        panel.Controls.Add(_btnReoptimizar);
        panel.Controls.Add(_btnCambiar);   // NUEVO
        panel.Controls.Add(_btnDisponibilidad);   // NUEVO
        panel.Controls.Add(_btnLimpiar);
        panel.Controls.Add(_btnRecargar);

        var barra = new StatusStrip();
        barra.Items.Add(_lblEstado);

        Controls.Add(_grid);
        Controls.Add(panel);
        Controls.Add(barra);

        // Se configuran los eventos de la pantalla
        Load += (_, _) => CargarPeriodos();
        _cmbPeriodo.SelectedIndexChanged += (_, _) => { if (!_cargando) Recargar(); };
        _btnRecargar.Click += (_, _) => Recargar();
        _btnAsignar.Click += (_, _) => Ejecutar(ModoAsignacion.Conservador);
        _btnReoptimizar.Click += (_, _) => Ejecutar(ModoAsignacion.Reoptimizar);
        _btnCambiar.Click += (_, _) => CambiarManual();                                                    // NUEVO
        _grid.CellDoubleClick += (_, e) => { if (e.RowIndex >= 0) CambiarManual(); };                      // NUEVO
        _grid.SelectionChanged += (_, _) => _btnCambiar.Enabled = _grid.CurrentRow?.Tag is Slot;          // NUEVO
        _btnDisponibilidad.Click += (_, _) => VerDisponibilidad();   // NUEVO
        _btnLimpiar.Click += (_, _) => Limpiar();
    }

    private PeriodoItem? PeriodoActual => _cmbPeriodo.SelectedItem as PeriodoItem;

    // ---------- Cargar y mostrar datos ----------
    private void CargarPeriodos()
    {
        try
        {
            _cargando = true;
            _cmbPeriodo.DataSource = _repo.Periodos();
            _cargando = false;
            Recargar();
        }
        catch (Exception ex) { Error("No se pudo conectar a la base de datos", ex); }
    }

    // Recarga los slots y maestros del periodo actual y los muestra en la tabla
    private void Recargar()
    {
        if (PeriodoActual is null) return;
        try
        {
            _slots = _repo.CargarSlots(PeriodoActual.Id);
            _maestros = _repo.CargarMaestros(PeriodoActual.Id);
            MostrarSlots();
        }
        catch (Exception ex) { Error("No se pudieron cargar los datos", ex); }
    }

    // Muestra los slots en la tabla y actualiza el estado de la pantalla
    private void MostrarSlots()
    {
        _grid.Rows.Clear();
        foreach (var s in _slots)
        {
            var i = _grid.Rows.Add(s.Paquete, s.Materia, s.Hora, NombreMaestro(s.IdMaestro), s.Estado.ToString(), s.Motivo);
            _grid.Rows[i].Tag = s;   // NUEVO: así la fila siempre sabe qué slot es, aunque el usuario ordene la tabla
            _grid.Rows[i].DefaultCellStyle.BackColor = s.Estado switch
            {
                EstadoSlot.Asignado => Color.Honeydew,
                EstadoSlot.Fijo => Color.AliceBlue,
                _ => Color.MistyRose,
            };
        }
        var pend = _slots.Count(s => s.Estado == EstadoSlot.Pendiente);
        _lblEstado.Text = $"{_slots.Count - pend} asignados · {pend} pendientes";
        _btnCambiar.Enabled = _grid.CurrentRow?.Tag is Slot;   // NUEVO
    }

    // Devuelve el nombre del maestro con su clave, o "—" si no hay maestro
    private string NombreMaestro(int? id) =>
        id is int i && _maestros.FirstOrDefault(m => m.Id == i) is { } m ? $"{m.Clave} · {m.Nombre}" : "—";

    // ---------- Asignación automática ----------
    private void Ejecutar(ModoAsignacion modo)
    {
        if (_slots.Count == 0) return;
        try
        {
            var resultado = Asignador.Asignar(_slots, _maestros, modo);
            ConfirmarYGuardar(resultado, modo == ModoAsignacion.Conservador ? "Asignacion" : "Reoptimizacion");
        }
        catch (Exception ex) { Error("No se pudo asignar", ex); }
    }

    // ---------- NUEVO: cambio manual ----------
    private void CambiarManual()
    {
        if (_grid.CurrentRow?.Tag is not Slot elegido) return;
        try
        {
            var slot = _slots.First(s => s.Id == elegido.Id);
            var opciones = AjusteManual.Opciones(_slots, _maestros, slot.Id);

            var situacion = slot.IdMaestro is null
                ? "Sin maestro (pendiente)."
                : $"Maestro actual: {NombreMaestro(slot.IdMaestro)} ({slot.Estado}).";
            if (slot.Estado == EstadoSlot.Pendiente && !string.IsNullOrEmpty(slot.Motivo))
                situacion += Environment.NewLine + slot.Motivo;

            using var dlg = new FrmCambioManual(slot.Etiqueta, situacion, opciones, puedeQuitar: slot.IdMaestro != null);
            if (dlg.ShowDialog(this) != DialogResult.OK) return;

            var resultado = dlg.QuitarMaestro
                ? AjusteManual.Quitar(_slots, slot.Id)
                : AjusteManual.Aplicar(_slots, slot.Id, dlg.OpcionElegida!);

            ConfirmarYGuardar(resultado, "Manual");
        }
        catch (Exception ex) { Error("No se pudo hacer el cambio", ex); }
    }

    /// <summary>Valida, muestra la vista previa y, si el usuario acepta, guarda solo la diferencia.</summary>
    private bool ConfirmarYGuardar(ResultadoAsignacion resultado, string origen)
    {
        var errores = Asignador.Validar(resultado.Slots, _maestros);
        if (errores.Count > 0)
        {
            MessageBox.Show(string.Join(Environment.NewLine, errores),
                "El resultado no es válido. No se guardó nada.", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return false;
        }

        if (resultado.Cambios.Count == 0)
        {
            MessageBox.Show("No hay nada que cambiar.", Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
            return false;
        }

        var visibles = resultado.Cambios.Where(c => c.CambiaMaestro || c.EstadoAnterior != c.EstadoNuevo).ToList();
        if (visibles.Count > 0)
        {
            var filas = visibles.Select(c => new[]
            {
                _slots.First(s => s.Id == c.IdSlot).Etiqueta,
                NombreMaestro(c.MaestroAnterior),
                NombreMaestro(c.MaestroNuevo),
                c.EstadoNuevo.ToString(),
            }).ToList();

            var pendAntes = _slots.Count(s => s.Estado == EstadoSlot.Pendiente);
            var resumen = $"{visibles.Count} slots cambian. Pendientes: {pendAntes} → {resultado.Pendientes}.";
            using var dlg = new FrmVistaPrevia(resumen, filas);
            if (dlg.ShowDialog(this) != DialogResult.OK) return false;
        }

        _repo.GuardarCambios(resultado.Cambios, origen);
        Recargar();
        return true;
    }

    // ---------- NUEVO: disponibilidad de todos los maestros ----------
    private void VerDisponibilidad()
    {
        try
        {
            var materias = _repo.CargarMaterias();
            var bloques = _repo.CargarBloques();
            using var frm = new FrmDisponibilidad(_maestros, _slots, materias, bloques);
            frm.ShowDialog(this);
        }
        catch (Exception ex) { Error("No se pudo mostrar la disponibilidad", ex); }
    }

    // ---------- Limpiar ----------
    private void Limpiar()
    {
        if (PeriodoActual is null) return;

        var conMaestro = _slots.Count(s => s.IdMaestro != null);
        var celdas = _maestros.Sum(m => m.Ofrece.Count);
        if (conMaestro == 0 && celdas == 0)
        {
            MessageBox.Show("No hay nada que limpiar.", Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var fijos = _slots.Count(s => s.Estado == EstadoSlot.Fijo);
        var nl = Environment.NewLine;
        var resumen = $"Periodo {PeriodoActual.Clave}:{nl}"
                    + $"• Se quitará el maestro de {conMaestro} slots" + (fijos > 0 ? $" ({fijos} fijos, hechos a mano)" : "") + $".{nl}"
                    + "• La materia y la hora de cada grupo se conservan; los slots quedan pendientes.";

        using var dlg = new FrmLimpiar(resumen, celdas);
        if (dlg.ShowDialog(this) != DialogResult.OK) return;

        if (dlg.IncluirDisponibilidad)
        {
            var seguro = MessageBox.Show(
                "Se borrará la disponibilidad de TODOS los maestros en este periodo y tendrás que capturarla de nuevo. ¿Seguro?",
                "Confirmar", MessageBoxButtons.YesNo, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
            if (seguro != DialogResult.Yes) return;
        }

        try
        {
            _repo.LimpiarPeriodo(PeriodoActual.Id, dlg.IncluirDisponibilidad);
            Recargar();
        }
        catch (Exception ex) { Error("No se pudo limpiar", ex); }
    }

    // Muestra un mensaje de error con el título y el mensaje de la excepción
    private void Error(string titulo, Exception ex) =>
        MessageBox.Show(ex.Message, titulo, MessageBoxButtons.OK, MessageBoxIcon.Error);
}
