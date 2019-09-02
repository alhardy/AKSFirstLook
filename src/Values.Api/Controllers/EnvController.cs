using System;
using Microsoft.AspNetCore.Mvc;

namespace Values.Api.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class EnvController : ControllerBase
    {
        [HttpGet]
        public ActionResult<string> Get()
        {
            return Environment.MachineName;
        }
    }
}