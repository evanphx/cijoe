class CIJoe
  module Irccat
    def self.activate
      if valid_config?
        CIJoe::Build.class_eval do
          include CIJoe::Irccat
        end

        puts "Loaded irccat notifier: port #{config[:port]}"
      else
        puts "Can't load irccat notifier."
        puts "Please add the following to your project's .git/config:"
        puts "[irccat]"
        puts "\tport = 3223"
      end
    end

    def self.config
      @config ||= {
        :port      => Config.irccat.port.to_s.to_i
      }
    end

    def self.valid_config?
      config[:port] > 0
    end

    def notify
      last_line = output.split(/\n/).last

      if failed?
        speak "CI: Commit #{short_sha} failed. #{commit.url}"
      else
        speak "CI: #{project}: #{short_sha} successful: #{last_line}"
      end
    end

    private

    def speak(str)
      sock = TCPSocket.new("127.0.0.1", Irccat.config[:port])
      sock.puts str
      sock.close
    end
  end
end
