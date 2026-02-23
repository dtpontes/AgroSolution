using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

namespace AgroSolutions.Shared.Messaging;

/// <summary>
/// Implementação do message bus usando RabbitMQ
/// </summary>
public class RabbitMQMessageBus : IMessageBus, IDisposable
{
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private bool _disposed;

    public RabbitMQMessageBus(string hostname)
    {
        var factory = new ConnectionFactory
        {
            HostName = hostname,
            AutomaticRecoveryEnabled = true,
            NetworkRecoveryInterval = TimeSpan.FromSeconds(10)
        };

        _connection = factory.CreateConnection();
        _channel = _connection.CreateModel();
    }

    public async Task PublishAsync<T>(string queue, T message)
    {
        _channel.QueueDeclare(
            queue: queue,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null);

        var json = JsonSerializer.Serialize(message);
        var body = Encoding.UTF8.GetBytes(json);

        var properties = _channel.CreateBasicProperties();
        properties.Persistent = true;
        properties.ContentType = "application/json";

        _channel.BasicPublish(
            exchange: string.Empty,
            routingKey: queue,
            basicProperties: properties,
            body: body);

        await Task.CompletedTask;
    }

    public async Task SubscribeAsync<T>(string queue, Func<T, Task> handler)
    {
        _channel.QueueDeclare(
            queue: queue,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null);

        // Configurar QoS (Quality of Service)
        _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);

        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += async (model, ea) =>
        {
            try
            {
                var body = ea.Body.ToArray();
                var json = Encoding.UTF8.GetString(body);
                var message = JsonSerializer.Deserialize<T>(json);

                if (message != null)
                {
                    await handler(message);
                }

                // Confirmar processamento com sucesso
                _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            }
            catch (Exception)
            {
                // Rejeitar mensagem e reenviar para a fila
                _channel.BasicNack(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel.BasicConsume(queue: queue, autoAck: false, consumer: consumer);
        await Task.CompletedTask;
    }

    public void Dispose()
    {
        if (_disposed)
            return;

        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();

        _disposed = true;
        GC.SuppressFinalize(this);
    }
}
