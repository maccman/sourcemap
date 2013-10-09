require 'source_map/offset'

module SourceMap
  class Mapping < Struct.new(:source, :generated, :original, :name)
    def to_s
      str = "#{generated.line}:#{generated.column}"
      str << "->#{original.line}:#{original.column}"
      str << "##{name}" if name
      str
    end

    alias_method :inspect, :to_s
  end
end
