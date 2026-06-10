using LDT.APP.Controllers.Interfaces;

namespace LDT.APP.Controllers.Implements
{
  public class BaseController<TEntity, TView, TModel, TService> : IBaseController<TEntity, TView, TModel, TService>
  {
    public BaseController(TView view, TModel model, TService service)
    {
      Tview = view;
      Tmodel = model;
      Tservice = service;
    }

    public virtual TView Tview { get; set; }
    public virtual TModel Tmodel { get; set; }
    public virtual TService Tservice { get; set; }
  }
}
