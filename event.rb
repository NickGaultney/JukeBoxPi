module AbstractInterface

  class InterfaceNotImplementedError < NoMethodError
  end

  def self.included(klass)
    klass.send(:include, AbstractInterface::Methods)
    klass.send(:extend, AbstractInterface::Methods)
  end

  module Methods

    def api_not_implemented(klass)
      caller.first.match(/in \`(.+)\'/)
      method_name = $1
      raise AbstractInterface::InterfaceNotImplementedError.new("#{klass.class.name} needs to implement '#{method_name}' for #{self.name} interface!")
    end

  end

end

class Event
  include AbstractInterface

  # Some documentation on the change_gear method
  def get_input
    Bicycle.api_not_implemented(self)
  end

  def self.parse_input(input)
		method_name = input[/^([\w\-]+)/]           # i[/^([\w\-]+)/] Takes first word of input
		method_args = input[/(?<=\s).*/] # i[/(?<=\s).*/] Takes every word except first
    method_args = method_args.split(/ /) if (!method_args.nil?)
		return [ method_name, method_args ]
  end

  def self.class_has_input?(class_name, input_string)
    input_array = self.parse_input(input_string)
    if class_name.method_defined?(input_array[0])      # Checks if given method exists
        return true
      else
        puts("Invalid command")                        # Exception if user input is not valid
        return false
      end
  end
end
