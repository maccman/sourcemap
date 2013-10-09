require 'source_map/offset'

module SourceMap
  Mapping = Struct.new(:source, :generated, :original, :name) do
    def to_s
      str = "#{generated.line}:#{generated.column}"
      str << "->#{original.line}:#{original.column}"
      str << "##{name}" if name
      str
    end

    alias_method :inspect, :to_s
  end
end
