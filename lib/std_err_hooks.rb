# This hooks into standard error to open backtraces in vim
class StandardError
  alias _backtrace backtrace
  def backtrace
    old = _backtrace
    @old_backtrace ||= nil
    if old.kind_of?(Array) and @old_backtrace.nil?
      open_vims(old)
      @old_backtrace = true
    end
    old
  end

  def open_vims(lines)
    good_lines = lines.select { |l| l.match(/^[\/\w][^:\s]*:\d+(?::.*)?$/) }.map do |line|
      file, line_number, rest = line.split(":")
      [file, line_number]
    end.uniq
    file, line = good_lines.shift
    if file.match("->")
      window = file.split("->")[1]
      %x{screen -X select #{window}}
      %x{screen -p #{window} -X stuff ":#{line}\n"}
      return
    end
    s = "screen vim -p"
    s << " +#{line} #{file}"
    # for handling multiple levels back, disabled for now
=begin
    good_lines.each do |l|
      file, line = l
      s << " -c tabnext -c #{line} #{file} "
    end
    s << " -c tabnext " if good_lines.size > 0
=end
    %x{screen -X #{s}}
  end
end
