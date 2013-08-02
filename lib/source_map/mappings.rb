require 'source_map/mapping'
require 'source_map/offset'
require 'source_map/vlq'

module SourceMap
  class Mappings
    include Enumerable

    def self.from_vlq(str, sources = [], names = [])
      mappings = []

      generated_line   = 0
      generated_column = 0
      source_id        = 0
      original_line    = 0
      original_column  = 0
      name_id          = 0

      str.split(';').each do |group|
        generated_column = 0
        generated_line += 1

        group.split(',').each do |segment|
          segment = VLQ.decode(segment)

          generated_column += segment[0]
          generated = Offset.new(generated_line, generated_column)

          if segment.size >= 4
            source_id        += segment[1]
            original_line    += segment[2]
            original_column  += segment[3]

            source   = sources[source_id]
            original = Offset.new(original_line, original_column)
          else
            # TODO: Research this case
            next
          end

          if segment[4]
            name_id += segment[4]
            name     = names[name_id]
          end

          mappings << Mapping.new(source, generated, original, name)
        end
      end

      new(mappings, :vlq => str, :sources => sources, :names => names)
    end

    def initialize(mappings = [], attrs = {})
      @mappings = mappings

      if attrs.key?(:sources) && sources != attrs[:sources]
        raise "DEBUG: #{sources.inspect} didn't equal #{attrs[:sources].inspect}"
      end

      if attrs.key?(:names) && names != attrs[:names]
        raise "DEBUG: #{names.inspect} didn't equal #{attrs[:names].inspect}"
      end

      if attrs.key?(:vlq) && to_s != attrs[:vlq]
        raise "DEBUG: #{to_s.inspect} didn't equal #{attrs[:vlq].inspect}"
      end
    end

    def line_count
      @line_count ||= @mappings.any? ? @mappings.last.generated.line : 0
    end

    def size
      @mappings.size
    end

    def [](i)
      @mappings[i]
    end

    def each(&block)
      @mappings.each(&block)
    end

    def to_s
      @string ||= build_vlq_string
    end

    def sources
      @sources ||= @mappings.map(&:source).uniq.compact
    end

    def names
      @names ||= @mappings.map(&:name).uniq.compact
    end

    def +(other)
      mappings = []
      mappings += @mappings
      offset = line_count+1
      other.each do |m|
        mappings << Mapping.new(m.source, m.generated + offset, m.original, m.name)
      end
      self.class.new(mappings)
    end

    def bsearch(offset, low = 0, high = size - 1)
      return self[low-1] if low > high
      mid = (low + high) / 2
      return self[mid] if self[mid] == offset
      if self[mid].generated > offset
        high = mid - 1
      else
        low = mid + 1
      end
      bsearch(offset, low, high)
    end

    protected
      def build_vlq_string
        source_id        = 0
        source_line      = 0
        source_column    = 0
        name_id          = 0

        by_lines = @mappings.group_by { |m| m.generated.line }

        (1..by_lines.keys.max+1).map do |line|
          generated_column = 0

          (by_lines[line] || []).map do |mapping|
            group = []
            group << mapping.generated.column - generated_column
            group << sources_index[mapping.source] - source_id
            group << mapping.original.line - source_line
            group << mapping.original.column - source_column
            group << names_index[mapping.name] - name_id if mapping.name

            generated_column = mapping.generated.column
            source_id        = sources_index[mapping.source]
            source_line      = mapping.original.line
            source_column    = mapping.original.column
            name_id          = names_index[mapping.name] if mapping.name

            VLQ.encode(group)
          end.join(",")
        end.join(";")
      end

      def sources_index
        @sources_index ||= build_index(sources)
      end

      def names_index
        @names_index ||= build_index(names)
      end

    private
      def build_index(array)
        index = {}
        array.each_with_index { |v, i| index[v] = i }
        index
      end
  end
end
