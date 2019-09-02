using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using NServiceBus;
using Values.Api.Infrastructure;

namespace Values.Api.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class CommandController : ControllerBase
    {
        private readonly Bus _bus;

        public CommandController(Bus bus)
        {
            _bus = bus;
        }
        
        [HttpPost]
        public async Task<ActionResult> Post(string[] values)
        {
            var command = new ValuesCommand(values);

            await _bus.Session.Send(command);

            return Accepted();
        }
    }
}