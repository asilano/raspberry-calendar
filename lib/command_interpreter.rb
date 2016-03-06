require 'show_command'

class CommandInterpreter
  def self.parse(input)
    case input
    when /^(please )*show (me )?(?<time>.*)$/i
      ShowCommand.new(Regexp::last_match[:time])
    end
  end
end