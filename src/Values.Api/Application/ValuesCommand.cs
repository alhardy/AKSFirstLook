using NServiceBus;

// ReSharper disable CheckNamespace
namespace Values
    // ReSharper restore CheckNamespace
{
    public class ValuesCommand : ICommand
    {
        public ValuesCommand(string[] values)
        {
            Values = values;
        }
        
        public string[] Values { get; }
    }
}