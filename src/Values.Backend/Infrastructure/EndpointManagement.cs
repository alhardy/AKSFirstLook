using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using NServiceBus;

namespace Values.Backend.Infrastructure
{
    public class EndpointManagement : IHostedService
    {
        private readonly Bus _bus;
        private IEndpointInstance _endpoint;

        public EndpointManagement(Bus bus) { _bus = bus; }

        public async Task StartAsync(CancellationToken cancellationToken)
        {
            _endpoint = await Endpoint.Start(_bus.Configuration).ConfigureAwait(false);
            _bus.Session = _endpoint;
        }

        public async Task StopAsync(CancellationToken cancellationToken)
        {
            await _endpoint.Stop().ConfigureAwait(false);

            _bus.Session = null;
        }
    }
}