module KnotHash
    class Rope
        attr_reader :values

        def initialize(length = 256)
            @length = length
            @skip_size = 0
            @total_rotation = 0
            @values = (0...@length).to_a
        end

        def checksum
            @values[0] * @values[1]
        end

        def correct!
            rotation = @length - (@total_rotation % @length)
            @values.rotate! rotation
        end

        def pinch!(length)
            # Reverse the values
            section = @values[0,length]
            @values[0,length] = section.reverse

            # Rotate the values past the reversed part
            rotation = length + @skip_size
            @values.rotate! rotation
            @total_rotation += rotation

            # Increment the skip
            @skip_size += 1
        end

        def print_rope
            # Get the rope rotates back
            rotation = @length - (@total_rotation % @length)
            rotated_values = @values.rotate rotation

            puts rotated_values.inspect
        end
    end

    class Hasher
        def initialize
            @rope = Rope.new 256
        end

        def hash!(lengths)
            64.times do
                lengths.each do |length|
                    @rope.pinch! length
                end
            end

            @rope.correct!
        end

        def hash_value
            @rope.values
                .each_slice(16)
                .map { |chunk| chunk.reduce(0) { |acc,value| acc ^ value } }
                .map { |value| "%02x" % value }
                .join
        end
    end
end