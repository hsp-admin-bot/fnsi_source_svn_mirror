namespace LDT.APP.Controllers.Interfaces
{
  public interface IBaseController<TEntity, TView, TModel, TService>
    {
        TView Tview { get; set; }
        TModel Tmodel { get; set; }
        TService Tservice { get; set; }
    }
}
