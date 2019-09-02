using System;
using System.Threading.Tasks;
using NServiceBus;

namespace Values.Backend.Application
{
    public class ValuesCommandHandler : IHandleMessages<ValuesCommand>
    {
        public Task Handle(ValuesCommand command, IMessageHandlerContext context)
        {
            Console.WriteLine($"Received command {command.GetType().Name} with values {string.Join(", ", command.Values)}");

            return Task.CompletedTask;
        }
    }
}