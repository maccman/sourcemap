require 'json'

require 'source_map/offset'
require 'source_map/vlq'

module SourceMap
  Mapping = Struct.new(:source, :generated, :original, :name)

  class Map
    include Enumerable

    def self.from_json(json)
      from_hash JSON.parse(json)
    end

    def self.from_hash(hash)
      str     = hash['mappings']
      sources = hash['sources']
      names   = hash['names']

      mappings = decode_vlq_mappings(str, sources, names)
      map = new(mappings, hash['file'])

      # Debug sanity checking. Eventually remove these validations
      if map.sources != sources
        raise "DEBUG: #{map.sources.inspect} didn't equal #{sources.inspect}"
      end
      if map.names != names
        raise "DEBUG: #{map.names.inspect} didn't equal #{names.inspect}"
      end
      if map.to_s != str
        raise "DEBUG: #{map.to_s.inspect} didn't equal #{str.inspect}"
      end

      map
    end

    # Internal: Decode VLQ mappings and match up sources and symbol names.
    #
    # str     - VLQ string from 'mappings' attribute
    # sources - Array of Strings from 'sources' attribute
    # names   - Array of Strings from 'names' attribute
    #
    # Returns an Array of Mappings.
    def self.decode_vlq_mappings(str, sources = [], names = [])
      mappings = []

      source_id       = 0
      original_line   = 0
      original_column = 0
      name_id         = 0

      VLQ.decode_mappings(str).each_with_index do |group, index|
        generated_column = 0
        generated_line   = index + 1

        (group || []).each do |segment|
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

      mappings
    end

    def initialize(mappings = [], filename = nil)
      @mappings, @filename = mappings, filename
    end

    attr_reader :filename

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

    def |(other)
      self
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

    def as_json
      {
        "version"   => 3,
        "file"      => filename,
        "lineCount" => line_count,
        "mappings"  => to_s,
        "sources"   => sources,
        "names"     => names
      }
    end

    protected
      def build_vlq_string
        source_id        = 0
        source_line      = 0
        source_column    = 0
        name_id          = 0

        by_lines = @mappings.group_by { |m| m.generated.line }

        ary = (1..by_lines.keys.max).map do |line|
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

            group
          end
        end

        VLQ.encode_mappings(ary)
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
