namespace AgroSolutions.Shared.Messaging;

/// <summary>
/// Interface para comunicação assíncrona entre serviços via message broker
/// </summary>
public interface IMessageBus
{
    /// <summary>
    /// Publica uma mensagem em uma fila
    /// </summary>
    Task PublishAsync<T>(string queue, T message);

    /// <summary>
    /// Inscreve um handler para processar mensagens de uma fila
    /// </summary>
    Task SubscribeAsync<T>(string queue, Func<T, Task> handler);
}
