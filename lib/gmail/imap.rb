module Gmail
	class Imap
    @@client = nil
    @@gmail_api = nil

    def self.get_messages
      messages = Array.new
      list_messages.each do |m|
        message = get_message(m.id)
        next unless message.payload.parts.first.present?
        messages << {id: m.id, snippet: message.snippet,
          body: message.payload.parts.first.body.data}
      end
      messages
    end


    private

    def self.get_message(message_id)
      check_client
      begin
        response = @@client.execute!(
          api_method: @@gmail_api.users.messages.get,
          parameters: {
            userId: 'me',
            id: message_id,
            format: 'full',
          }
        )
        return response.data
      rescue Google::APIClient::TransmissionError => e
        raise e.result.body
      end
    end

    def self.list_messages
      check_client
      begin
        response = @@client.execute!(
          api_method: @@gmail_api.users.messages.list,
          parameters: {
            userId: 'me',
            maxResults: 25,
          }
        )
        return response.data.messages
      rescue Google::APIClient::TransmissionError => e
        raise e.result.body
      end
    end

    def self.check_client
     return '' if @@client.present? && @@gmail_api.present?
     @@client, @@gmail_api = Initializer.new
    end

   end

 end
