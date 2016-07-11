#!/usr/bin/env ruby

require 'optparse'

require_relative 'func.rb'

# the name of the language must be lowercase, but Ruby does not like that :(
# Cslaka stands for "class slaka"
class Cslaka

    attr_accessor :vars

    # all of the operators (consonants)
    @@ops = [
        ['c', 'ɟ', :concat],
        ['s', 'z', :add],       # mnemonic: sum
        ['t', 'd', :subtract],  # mnemonic: difference
        ['p', 'b', :multiply],  # mnemonic: product
        ['q', 'ɢ', :divide]     # mnemonic: quotient
    ].map{|unvoiced, voiced, func|
        # I am sorry for the following lines of code
        {
            unvoiced       => -> slaka, args { slaka.vars[args[0]] = Func.send func, slaka.vars[args[0]], slaka.vars[args[1]] },
            unvoiced + 'ʰ' => -> slaka, args { slaka.vars[args[1]] = Func.send func, slaka.vars[args[0]], slaka.vars[args[1]] },
            voiced         => -> slaka, args { slaka.vars[args[0]] = Func.send func, slaka.vars[args[1]], slaka.vars[args[0]] },
            voiced + 'ʰ'   => -> slaka, args { slaka.vars[args[1]] = Func.send func, slaka.vars[args[1]], slaka.vars[args[0]] }
        }
    }.reduce({
        'ʔ' => -> slaka, args {
            slaka.vars[args[0]] = gets || ''
        },
        'ʔʰ' => -> slaka, args {
            print slaka.vars[args[0]]
        }
    }, :merge)

    # a list of the argument pairs (vowels) in order
    @@vowels = ['i', 'y', 'ɨ', 'ʉ', 'ɯ', 'u', 'ɪ', 'ʏ', 'ɪ̈', 'ʊ̈', 'ɯ̽', 'ʊ',
                'e', 'ø', 'ɘ', 'ɵ', 'ɤ', 'o', 'ɛ', 'œ', 'ɜ', 'ɞ', 'ʌ', 'ɔ',
                'æ', 'œ̞', 'ɐ', 'ɞ̞', 'ʌ̞', 'ɔ̞', 'a', 'ɶ', 'ä', 'ɒ̈', 'ɑ', 'ɒ']
    @@arg_pairs = *[*0..8].combination(2)

    def initialize
        # initialize all variables to empty string
        @vars = Array.new(9) { '' }
    end

    # executes slaka code from a string
    def run code
        if code.index ?/
            # if there are slashes, run the code between each pair
            code.split(?/, -1)[1...-1].each_with_index do |part, idx|
                run part if idx.even?
            end
        else
            # if there are no slashes, implicitly surround the code with them
            until code.empty?

                # find an operator that the code starts with
                op = @@ops.map{|k, v|
                    match = code.match /\A#{k}(#{@@vowels.join ?|})/
                    {name: k, fn: v, args: match[1]} if match
                }.compact.first

                if op
                    # remove operator from the string and call the
                    # corresponding function
                    code.slice! 0...op[:name].length
                    op[:fn][self, @@arg_pairs[@@vowels.index op[:args]]]
                else
                    # no operator found; discard this character
                    code.slice! 0
                end

            end
        end
    end

end

if __FILE__ == $0

    slaka = Cslaka.new

    parser = OptionParser.new do |opts|

        opts.banner = "Usage: #{$0} [options...] [filename]"

        opts.on '-h', '--help', 'output this help' do
            puts opts
            exit
        end

        opts.on '-e', '--exec CODE', 'execute code given as an argument' do |code|
            slaka.run code
            exit
        end

        opts.on '-i', '--interactive', 'start a REPL environment' do
            loop {
                print '>>> '
                exit unless gets
                puts slaka.run $_.chomp
            }
        end

    end

    parser.parse!

    if ARGV.length > 1
        # we have leftover (extraneous) free arguments
        puts parser.help
        exit
    end

    # if no filename is provided, default to STDIN
    filename = ARGV.shift || '-'

    # read code from file
    code = if filename == '-'
               STDIN
           else
               open filename
           end.read

    slaka.run code

end
