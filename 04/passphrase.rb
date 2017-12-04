#!/usr/bin/env ruby

def is_valid_simple?(phrase)
  words = phrase.chomp.split ' '
  filtered_words = words.uniq

  words.count == filtered_words.count
end

def is_valid_complex?(phrase)
  words = phrase.chomp.split ' '

  filtered_words = words.map { |word| word.split('').sort.join('') }.uniq

  words.count == filtered_words.count
end

valid_count_simple = 0
valid_count_complex = 0

# Read all of the data from STDIN
ARGF.each_line do |line|
  valid_count_simple += 1 if is_valid_simple? line
  valid_count_complex += 1 if is_valid_complex? line
end

puts "Valid Simple: #{valid_count_simple}"
puts "Valid Complex: #{valid_count_complex}"
