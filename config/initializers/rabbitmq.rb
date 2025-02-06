require 'bunny'

module RabbitMQ
  def self.connection
    @connection ||= Bunny.new(hostname: 'localhost')
  end

  def self.channel
    @channel ||= connection.start.create_channel
  end
end
