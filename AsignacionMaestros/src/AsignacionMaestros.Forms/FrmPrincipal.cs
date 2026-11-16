using AsignacionMaestros.Core;
using AsignacionMaestros.Forms.Datos;

namespace AsignacionMaestros.Forms;

public sealed class FrmPrincipal : Form
{
    private readonly Repositorio _repo;

    // ---------- Colores del diseño ----------
    private static readonly Color ColFondo = Color.FromArgb(227, 237, 247);
    private static readonly Color ColLateral = Color.FromArgb(185, 205, 224);
    private static readonly Color ColAreaTarjetas = Color.FromArgb(214, 228, 242);
    private static readonly Color ColTexto = Color.FromArgb(35, 55, 80);
    private static readonly Color ColSeleccion = Color.FromArgb(255, 248, 220);

    // ---------- Controles de Periodo y Filtros ----------
    private readonly ComboBox _cmbPeriodo = CrearComboFiltro(135);
    private readonly ComboBox _cmbFiltroMaestro = CrearComboFiltro(200);
    private readonly ComboBox _cmbFiltroMateria = CrearComboFiltro(185);
    private readonly ComboBox _cmbFiltroPaquete = CrearComboFiltro(85);
    private readonly ComboBox _cmbFiltroHora = CrearComboFiltro(85);
    private readonly ComboBox _cmbFiltroEstado = CrearComboFiltro(110);
    private readonly Button _btnLimpiarFiltros = new()
    {
        Text = "✖ Limpiar filtros",
        AutoSize = true,
        Height = 27,
        BackColor = Color.White,
        ForeColor = ColTexto,
        FlatStyle = FlatStyle.Flat,
        Font = new Font("Segoe UI", 9f, FontStyle.Bold),
        Margin = new Padding(4, 2, 0, 4),
        Cursor = Cursors.Hand,
    };

    // Botones superiores (de colores)
    private readonly Button _btnAsignar = Boton("Asignar automáticamente", Color.FromArgb(224, 181, 101));
    private readonly Button _btnReoptimizar = Boton("Reoptimizar todo", Color.FromArgb(91, 181, 154));
    private readonly Button _btnCambiar = Boton("Asignar maestro", Color.FromArgb(91, 127, 163));
    private readonly Button _btnLimpiar = Boton("Reiniciar todo", Color.FromArgb(229, 83, 75));
    private readonly Button _btnRecargar = Boton("Recarga", Color.FromArgb(122, 122, 122));

    // Botones de la barra lateral
    private readonly Button _btnVerMaestros = BotonLateral("👤  Ver maestros");
    private readonly Button _btnEditar = BotonLateral("✏  Editar registro");

    // Totales
    private readonly Label _lblTotal = Cifra();
    private readonly Label _lblAsignados = Cifra();
    private readonly Label _lblPendientes = Cifra();

    private readonly FlowLayoutPanel _tarjetas = new()
    {
        Dock = DockStyle.Fill,
        AutoScroll = true,
        WrapContents = true,
        Padding = new Padding(10),
        BackColor = ColAreaTarjetas,
    };
    private readonly ToolTip _tip = new() { InitialDelay = 200 };

    private List<Slot> _slots = new();
    private List<Maestro> _maestros = new();
    private bool _cargando;
    private int? _idSeleccionado;

    private sealed record FiltroMaestroItem(int? Id, string Texto)
    {
        public override string ToString() => Texto;
    }

    public FrmPrincipal(Repositorio repo)
    {
        _repo = repo;
        Text = "Asignación de maestros";
        Size = new Size(1280, 760);
        MinimumSize = new Size(980, 580);
        StartPosition = FormStartPosition.CenterScreen;
        BackColor = ColFondo;
        Font = new Font("Segoe UI", 10f);
        _btnCambiar.Enabled = false;
        _btnLimpiarFiltros.FlatAppearance.BorderColor = Color.FromArgb(180, 195, 210);

        // ----- Barra lateral -----
        var lateral = new FlowLayoutPanel
        {
            Dock = DockStyle.Left,
            Width = 205,
            BackColor = ColLateral,
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
            Padding = new Padding(10, 20, 10, 10),
        };
        lateral.Controls.Add(_btnVerMaestros);
        lateral.Controls.Add(_btnEditar);

        // ----- Parte superior: botones + dos filas fijas de filtros -----
        var botones = new FlowLayoutPanel
        {
            Dock = DockStyle.Top,
            Height = 48,
            Padding = new Padding(10, 8, 10, 0),
            WrapContents = false,
        };
        botones.Controls.AddRange(new Control[] { _btnAsignar, _btnReoptimizar, _btnCambiar, _btnLimpiar, _btnRecargar });

        var filaFiltros1 = new FlowLayoutPanel
        {
            Dock = DockStyle.Top,
            Height = 38,
            Padding = new Padding(10, 4, 10, 0),
            WrapContents = false,
        };
        AgregarCampoFiltro(filaFiltros1, "Periodo:", _cmbPeriodo);
        AgregarSeparador(filaFiltros1);
        AgregarCampoFiltro(filaFiltros1, "Maestro:", _cmbFiltroMaestro);
        AgregarCampoFiltro(filaFiltros1, "Materia:", _cmbFiltroMateria);

        var filaFiltros2 = new FlowLayoutPanel
        {
            Dock = DockStyle.Top,
            Height = 40,
            Padding = new Padding(10, 4, 10, 4),
            WrapContents = false,
        };
        AgregarCampoFiltro(filaFiltros2, "Paquete:", _cmbFiltroPaquete);
        AgregarCampoFiltro(filaFiltros2, "Hora:", _cmbFiltroHora);
        AgregarCampoFiltro(filaFiltros2, "Estado:", _cmbFiltroEstado);
        filaFiltros2.Controls.Add(_btnLimpiarFiltros);

        var superior = new Panel
        {
            Dock = DockStyle.Top,
            Height = 130,
        };
        // En paneles con Dock = Top, el último agregado queda más arriba
        superior.Controls.Add(filaFiltros2);
        superior.Controls.Add(filaFiltros1);
        superior.Controls.Add(botones);

        // ----- Parte inferior: totales -----
        var totales = new TableLayoutPanel
        {
            Dock = DockStyle.Bottom,
            Height = 78,
            ColumnCount = 3,
            BackColor = Color.White,
            Padding = new Padding(10),
        };
        for (var i = 0; i < 3; i++) totales.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 33.33f));
        totales.Controls.Add(BloqueTotal("Slots mostrados", _lblTotal), 0, 0);
        totales.Controls.Add(BloqueTotal("Asignados", _lblAsignados), 1, 0);
        totales.Controls.Add(BloqueTotal("Pendientes", _lblPendientes), 2, 0);

        // El orden importa: el último en agregarse se acomoda primero
        Controls.Add(_tarjetas);
        Controls.Add(totales);
        Controls.Add(superior);
        Controls.Add(lateral);

        // ----- Eventos -----
        Load += (_, _) => CargarPeriodos();
        _cmbPeriodo.SelectedIndexChanged += (_, _) => { if (!_cargando) Recargar(); };

        // Eventos de filtrado en tiempo real
        _cmbFiltroMaestro.SelectedIndexChanged += (_, _) => { if (!_cargando) MostrarSlots(); };
        _cmbFiltroMateria.SelectedIndexChanged += (_, _) => { if (!_cargando) MostrarSlots(); };
        _cmbFiltroPaquete.SelectedIndexChanged += (_, _) => { if (!_cargando) MostrarSlots(); };
        _cmbFiltroHora.SelectedIndexChanged += (_, _) => { if (!_cargando) MostrarSlots(); };
        _cmbFiltroEstado.SelectedIndexChanged += (_, _) => { if (!_cargando) MostrarSlots(); };
        _btnLimpiarFiltros.Click += (_, _) => ReiniciarFiltros();

        _btnRecargar.Click += (_, _) => Recargar();
        _btnAsignar.Click += (_, _) => Ejecutar(ModoAsignacion.Conservador);
        _btnReoptimizar.Click += (_, _) => Ejecutar(ModoAsignacion.Reoptimizar);
        _btnCambiar.Click += (_, _) => CambiarManual();
        _btnEditar.Click += (_, _) => CambiarManual();
        _btnVerMaestros.Click += (_, _) => VerDisponibilidad();
        _btnLimpiar.Click += (_, _) => Limpiar();
    }

    private PeriodoItem? PeriodoActual => _cmbPeriodo.SelectedItem as PeriodoItem;

    // ---------- Fábricas de controles ----------
    private static ComboBox CrearComboFiltro(int ancho) => new()
    {
        DropDownStyle = ComboBoxStyle.DropDownList,
        Width = ancho,
        Font = new Font("Segoe UI", 9.5f),
        Margin = new Padding(0, 2, 10, 4)
    };

    private static void AgregarCampoFiltro(FlowLayoutPanel panel, string etiqueta, ComboBox combo)
    {
        panel.Controls.Add(new Label
        {
            Text = etiqueta,
            AutoSize = true,
            Margin = new Padding(0, 6, 4, 4),
            ForeColor = ColTexto,
            Font = new Font("Segoe UI", 9.5f, FontStyle.Bold)
        });
        panel.Controls.Add(combo);
    }

    private static void AgregarSeparador(FlowLayoutPanel panel)
    {
        panel.Controls.Add(new Label
        {
            Text = "|",
            AutoSize = true,
            Margin = new Padding(0, 5, 8, 4),
            ForeColor = Color.FromArgb(150, 170, 190),
            Font = new Font("Segoe UI", 11f)
        });
    }

    private static Button Boton(string texto, Color color)
    {
        var b = new Button
        {
            Text = texto,
            AutoSize = true,
            MinimumSize = new Size(155, 36),
            BackColor = color,
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 9.5f, FontStyle.Bold),
            Margin = new Padding(0, 0, 12, 4),
            Cursor = Cursors.Hand,
        };
        b.FlatAppearance.BorderSize = 0;
        return b;
    }

    private static Button BotonLateral(string texto)
    {
        var b = new Button
        {
            Text = texto,
            Size = new Size(180, 42),
            BackColor = Color.White,
            ForeColor = ColTexto,
            FlatStyle = FlatStyle.Flat,
            TextAlign = ContentAlignment.MiddleLeft,
            Padding = new Padding(8, 0, 0, 0),
            Margin = new Padding(0, 0, 0, 12),
            Cursor = Cursors.Hand,
        };
        b.FlatAppearance.BorderColor = Color.FromArgb(200, 210, 222);
        return b;
    }

    private static Label Cifra() => new()
    {
        AutoSize = true,
        Font = new Font("Segoe UI", 16f, FontStyle.Bold),
        ForeColor = ColTexto,
        Text = "0",
    };

    private static Control BloqueTotal(string titulo, Label cifra)
    {
        var p = new FlowLayoutPanel { Dock = DockStyle.Fill, FlowDirection = FlowDirection.TopDown, WrapContents = false };
        p.Controls.Add(new Label { Text = titulo, AutoSize = true, ForeColor = ColTexto });
        p.Controls.Add(cifra);
        return p;
    }

    // ---------- Tarjetas ----------
    private Panel CrearTarjeta(Slot s)
    {
        var card = new Panel
        {
            Size = new Size(280, 190),
            Margin = new Padding(10),
            BackColor = Color.White,
            BorderStyle = BorderStyle.FixedSingle,
            Tag = s.Id,
        };

        card.Controls.Add(new Label
        {
            Text = $"🕗  {s.Hora}",
            Location = new Point(10, 8),
            AutoSize = true,
            Font = new Font("Segoe UI", 15f, FontStyle.Bold),
            ForeColor = ColTexto,
        });
        Fila(card, "Paquete", $"{s.Paquete}", 52);
        Fila(card, "Materia", $"{s.Materia}", 80);
        Fila(card, "Maestro", s.IdMaestro is null ? "Pendiente" : NombreMaestro(s.IdMaestro), 108);

        var (texto, fondo, letra) = s.Estado switch
        {
            EstadoSlot.Asignado => ("✔ Asignado", Color.FromArgb(102, 204, 110), Color.Black),
            EstadoSlot.Fijo => ("📌 Fijo", Color.FromArgb(150, 185, 225), Color.Black),
            _ => ("⏳ Pendiente", Color.FromArgb(224, 181, 101), Color.Black),
        };
        card.Controls.Add(new Label { Text = "Estado", Location = new Point(10, 142), AutoSize = true, ForeColor = ColTexto });
        var pill = new Label
        {
            Text = texto,
            Location = new Point(95, 138),
            Size = new Size(120, 28),
            TextAlign = ContentAlignment.MiddleCenter,
            BackColor = fondo,
            ForeColor = letra,
            Font = new Font("Segoe UI", 9.5f, FontStyle.Bold),
        };
        card.Controls.Add(pill);

        if (!string.IsNullOrWhiteSpace(s.Motivo))
        {
            _tip.SetToolTip(pill, "Motivo: " + s.Motivo);
            _tip.SetToolTip(card, "Motivo: " + s.Motivo);
        }

        ConectarClics(card, s.Id);
        return card;
    }

    private static void Fila(Panel card, string titulo, string valor, int y)
    {
        card.Controls.Add(new Label { Text = titulo, Location = new Point(10, y), AutoSize = true, ForeColor = ColTexto });
        card.Controls.Add(new Label
        {
            Text = valor,
            Location = new Point(95, y),
            Size = new Size(175, 24),
            AutoEllipsis = true,
            Font = new Font("Segoe UI", 10f, FontStyle.Bold),
            ForeColor = Color.Black,
        });
    }

    private void ConectarClics(Control c, int idSlot)
    {
        c.Click += (_, _) => Seleccionar(idSlot);
        c.DoubleClick += (_, _) => { Seleccionar(idSlot); CambiarManual(); };
        foreach (Control hijo in c.Controls) ConectarClics(hijo, idSlot);
    }

    private void Seleccionar(int idSlot)
    {
        _idSeleccionado = idSlot;
        foreach (Control c in _tarjetas.Controls)
            c.BackColor = c.Tag is int id && id == idSlot ? ColSeleccion : Color.White;
        _btnCambiar.Enabled = true;
    }

    // ---------- Cargar, poblar filtros y mostrar datos ----------
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

    private void Recargar()
    {
        if (PeriodoActual is null) return;
        try
        {
            _slots = _repo.CargarSlots(PeriodoActual.Id);
            _maestros = _repo.CargarMaestros(PeriodoActual.Id);
            PoblarFiltros();
            MostrarSlots();
        }
        catch (Exception ex) { Error("No se pudieron cargar los datos", ex); }
    }

    private void PoblarFiltros()
    {
        var maestroPrevio = (_cmbFiltroMaestro.SelectedItem as FiltroMaestroItem)?.Id;
        var materiaPrevia = _cmbFiltroMateria.SelectedItem?.ToString();
        var paquetePrevio = _cmbFiltroPaquete.SelectedItem?.ToString();
        var horaPrevia = _cmbFiltroHora.SelectedItem?.ToString();
        var estadoPrevio = _cmbFiltroEstado.SelectedItem?.ToString();

        _cargando = true;
        try
        {
            var listaMaestros = new List<FiltroMaestroItem>
            {
                new(null, "Todos los maestros"),
                new(-1, "⏳ Sin asignar (Pendientes)")
            };
            listaMaestros.AddRange(_maestros
                .OrderBy(m => m.Clave)
                .Select(m => new FiltroMaestroItem(m.Id, $"{m.Clave} · {m.Nombre}")));
            _cmbFiltroMaestro.DataSource = listaMaestros;
            var idxMaestro = listaMaestros.FindIndex(x => x.Id == maestroPrevio);
            _cmbFiltroMaestro.SelectedIndex = idxMaestro >= 0 ? idxMaestro : 0;

            var materias = new List<string> { "Todas las materias" };
            materias.AddRange(_slots.Select(s => s.Materia).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct().OrderBy(x => x));
            _cmbFiltroMateria.DataSource = materias;
            _cmbFiltroMateria.SelectedIndex = materiaPrevia != null && materias.Contains(materiaPrevia) ? materias.IndexOf(materiaPrevia) : 0;

            var paquetes = new List<string> { "Todos" };
            paquetes.AddRange(_slots.Select(s => s.Paquete).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct().OrderBy(x => x));
            _cmbFiltroPaquete.DataSource = paquetes;
            _cmbFiltroPaquete.SelectedIndex = paquetePrevio != null && paquetes.Contains(paquetePrevio) ? paquetes.IndexOf(paquetePrevio) : 0;

            var horas = new List<string> { "Todas" };
            horas.AddRange(_slots.Select(s => s.Hora).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct().OrderBy(x => x));
            _cmbFiltroHora.DataSource = horas;
            _cmbFiltroHora.SelectedIndex = horaPrevia != null && horas.Contains(horaPrevia) ? horas.IndexOf(horaPrevia) : 0;

            var estados = new List<string> { "Todos", "Asignado", "Fijo", "Pendiente" };
            _cmbFiltroEstado.DataSource = estados;
            _cmbFiltroEstado.SelectedIndex = estadoPrevio != null && estados.Contains(estadoPrevio) ? estados.IndexOf(estadoPrevio) : 0;
        }
        finally
        {
            _cargando = false;
        }
    }

    private void ReiniciarFiltros()
    {
        _cargando = true;
        if (_cmbFiltroMaestro.Items.Count > 0) _cmbFiltroMaestro.SelectedIndex = 0;
        if (_cmbFiltroMateria.Items.Count > 0) _cmbFiltroMateria.SelectedIndex = 0;
        if (_cmbFiltroPaquete.Items.Count > 0) _cmbFiltroPaquete.SelectedIndex = 0;
        if (_cmbFiltroHora.Items.Count > 0) _cmbFiltroHora.SelectedIndex = 0;
        if (_cmbFiltroEstado.Items.Count > 0) _cmbFiltroEstado.SelectedIndex = 0;
        _cargando = false;
        MostrarSlots();
    }

    private List<Slot> ObtenerSlotsFiltrados()
    {
        IEnumerable<Slot> consulta = _slots;

        if (_cmbFiltroMaestro.SelectedItem is FiltroMaestroItem fm && fm.Id is int idMaestro)
        {
            consulta = idMaestro == -1
                ? consulta.Where(s => s.IdMaestro == null)
                : consulta.Where(s => s.IdMaestro == idMaestro);
        }

        if (_cmbFiltroMateria.SelectedIndex > 0 && _cmbFiltroMateria.SelectedItem is string mat)
            consulta = consulta.Where(s => s.Materia == mat);

        if (_cmbFiltroPaquete.SelectedIndex > 0 && _cmbFiltroPaquete.SelectedItem is string paq)
            consulta = consulta.Where(s => s.Paquete == paq);

        if (_cmbFiltroHora.SelectedIndex > 0 && _cmbFiltroHora.SelectedItem is string hora)
            consulta = consulta.Where(s => s.Hora == hora);

        if (_cmbFiltroEstado.SelectedIndex > 0 && _cmbFiltroEstado.SelectedItem is string est)
        {
            consulta = est switch
            {
                "Asignado" => consulta.Where(s => s.Estado == EstadoSlot.Asignado),
                "Fijo" => consulta.Where(s => s.Estado == EstadoSlot.Fijo),
                "Pendiente" => consulta.Where(s => s.Estado == EstadoSlot.Pendiente),
                _ => consulta
            };
        }

        return consulta
            .OrderBy(s => s.Paquete)
            .ThenBy(s => s.Hora)
            .ToList();
    }

    private void MostrarSlots()
    {
        var visibles = ObtenerSlotsFiltrados();

        _tarjetas.SuspendLayout();
        foreach (var c in _tarjetas.Controls.Cast<Control>().ToList()) c.Dispose();
        _tarjetas.Controls.Clear();
        foreach (var s in visibles) _tarjetas.Controls.Add(CrearTarjeta(s));
        _tarjetas.ResumeLayout();

        var pend = visibles.Count(s => s.Estado == EstadoSlot.Pendiente);
        _lblTotal.Text = visibles.Count == _slots.Count
            ? _slots.Count.ToString()
            : $"{visibles.Count} de {_slots.Count}";
        _lblAsignados.Text = (visibles.Count - pend).ToString();
        _lblPendientes.Text = pend.ToString();

        if (_idSeleccionado is int id && visibles.Any(s => s.Id == id)) Seleccionar(id);
        else { _idSeleccionado = null; _btnCambiar.Enabled = false; }
    }

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

    // ---------- Cambio manual ----------
    private void CambiarManual()
    {
        if (_idSeleccionado is not int idElegido)
        {
            MessageBox.Show("Primero selecciona una tarjeta.", Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        try
        {
            var slot = _slots.First(s => s.Id == idElegido);
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

    // ---------- Disponibilidad de todos los maestros ----------
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

    private void Error(string titulo, Exception ex) =>
        MessageBox.Show(ex.Message, titulo, MessageBoxButtons.OK, MessageBoxIcon.Error);
}