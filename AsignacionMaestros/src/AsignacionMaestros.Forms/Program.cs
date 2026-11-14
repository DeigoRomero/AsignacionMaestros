using AsignacionMaestros.Forms.Datos;

namespace AsignacionMaestros.Forms;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new FrmPrincipal(new Repositorio(Configuracion.CadenaConexion)));
    }
}
