class Service::MqttPub < Service
  string :broker, :port, :topic, :id
  
  require 'mqtt'

  def receive_push
 
    if data['broker'].to_s == ''
      raise_config_error "Invalid broker endpoint."
    end
    
    port = data['port'].to_i
    if data['port'].to_s == '' 
      port = 1883
    end
    
    if data['topic'].to_s == ''
      raise_config_error "Invalid topic. Try github/<github_username>/<repo_name> ."
    end
    
    # Generate random epoch for ID if not specified
    client_id = data['id'].to_s
    if client_id == ''
      client_id = Time.now.to_i.to_s
    end
          
    begin
      # Connect to the broker, publish the payload!    
      MQTT::Client.connect(
        :remote_host => data['broker'].to_s, 
        :remote_port => port,
        :client_id => client_id
      ) do |client|
          client.publish(data['topic'].to_s, payload.to_json)
          # Disconnect (don't send last will and testament)
          client.disconnect(false)
        end
    rescue SocketError => e
      warn "SocketError occurred: " + e     
    end

  end
  

end
