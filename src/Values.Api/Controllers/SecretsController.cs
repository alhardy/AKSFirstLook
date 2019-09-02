using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace Values.Api.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class SecretsController : ControllerBase
    {
        private readonly Secrets _secrets;

        public SecretsController(IOptions<Secrets> secrets)
        {
            _secrets = secrets.Value;
        }
        
        [HttpGet]
        public ActionResult<Secrets> Get()
        {
            return _secrets;
        }
    }
}