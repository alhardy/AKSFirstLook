
using System;
using System.Threading.Tasks;
using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.Configuration;
using NServiceBus;
using NServiceBus.Features;
using Values.Backend.Infrastructure;

// ReSharper disable CheckNamespace
namespace Microsoft.Extensions.DependencyInjection
    // ReSharper restore CheckNamespace
{
    // ReSharper disable UnusedMember.Global
    public static class StartupNServiceBus
        // ReSharper restore UnusedMember.Global
    {
        public static IServiceCollection AddNServiceBus(
            this IServiceCollection services,
            IConfiguration configuration,
            string endpointName)
        {
            var connectionString = configuration.GetValue<string>("Secrets:ServiceBusConnectionString");
            var connection = new ServiceBusConnectionStringBuilder(connectionString);

            var cfg = new EndpointConfiguration(endpointName);
            cfg.SendFailedMessagesTo("error");
            cfg.EnableInstallers();
            cfg.DisableFeature<AutoSubscribe>();

            var serialization = cfg.UseSerialization<NewtonsoftSerializer>();
            serialization.Settings(DefaultPersistenceCamelCaseJsonSerializerSettings.Instance);

            cfg.CustomDiagnosticsWriter(diagnostics => Task.CompletedTask);

            cfg.Recoverability().Immediate(c => c.NumberOfRetries(1)).Delayed(c => c.NumberOfRetries(5).TimeIncrease(TimeSpan.FromSeconds(2)));

            cfg.UniquelyIdentifyRunningInstance().UsingNames(endpointName, Environment.MachineName);

            var pipeline = cfg.Pipeline;
            pipeline.StripAssemblyVersionFromEnclosedMessageTypePipeline();

            var transport = cfg.UseTransport<AzureServiceBusTransport>();
            transport.ConnectionString(connection.ToString);
            
            var management = new Bus(cfg);
            services.AddSingleton(provider => management.Session);
            services.AddSingleton(management);
            services.AddHostedService<EndpointManagement>();

            cfg.UseContainer<ServicesBuilder>(customizations => { customizations.ExistingServices(services); });

            return services;
        }
    }

}