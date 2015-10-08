module Gmail
  class Initializer
    require 'google/api_client'
    require 'google/api_client/client_secrets'
    require 'google/api_client/auth/installed_app'
    require 'google/api_client/auth/storage'
    require 'google/api_client/auth/storages/file_store'
    require 'fileutils'

    APPLICATION_NAME = 'Mail X'
    CREDENTIALS_PATH = File.join(Rails.root, 'config', 'credentials.json')
    CLIENT_SECRETS_PATH = File.join(Rails.root, 'config',
      'client_secrets.json')
    SCOPE = 'https://www.googleapis.com/auth/gmail.readonly'

    # Initialize the API
    def self.new
      client = Google::APIClient.new(:application_name => APPLICATION_NAME)
      client.authorization = authorize
      gmail_api = client.discovered_api('gmail', 'v1')

      return client, gmail_api
    end


    private

    def self.authorize
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

      file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
      storage = Google::APIClient::Storage.new(file_store)
      auth = storage.authorize

      if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
        app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
        flow = Google::APIClient::InstalledAppFlow.new({
          :client_id => app_info.client_id,
          :client_secret => app_info.client_secret,
          :scope => SCOPE})
        auth = flow.authorize(storage)
        puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
      end
      auth
    end

  end
end
