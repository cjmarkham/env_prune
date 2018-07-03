#!/usr/bin/env ruby

#################################
# Created by Cjmarkham
# https://github.com/cjmarkham
#################################

require 'find'

class EnvPrune
  $env_file = './.env'
  $envs = {}
  $used_envs = {}
  $search_dirs = %w(app config lib)
  $files = []
  $extensions = %w(rb)
  $verbose = false

  def call
    parse_args

    if $extensions.length == 0
      puts 'No extensions passed'
      exit 1
    end

    if $search_dirs.length == 0
      puts 'No directories to search'
      exit 1
    end

    get_files
    get_envs

    puts "Found #{colorize($files.length, 33)} files matching extensions #{colorize($extensions.join('|'), 33)} in #{colorize($search_dirs.join(', '), 33)}"
    exit if $files.length == 0

    get_unused

    puts "The following are unused:"
    puts $envs.reject{|k| $used_envs[k] }.keys
  end

  def parse_args
    # https://stackoverflow.com/a/26435303/630780
    args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
    return unless args.length

    if args['f']
      $env_file = args['f']
    end

    if args['d']
      $search_dirs = args['d'].split(',')
    end

    if args['e']
      $extensions = args['e'].split(',')
    end

    if args.key? 'v'
      $verbose = true
    end
  end

  def colorize string, code
    "\e[#{code}m#{string}\e[0m"
  end

  def get_files
    $search_dirs.each do |dir|
      begin
        Find.find(dir) do |path|
          $files << path if path =~ /.*\.#{$extensions.join('|')}$/

          puts "Found file #{path}" if $verbose
        end
      rescue Errno::ENOENT => e
        puts "Could not find directory #{dir}"
      end
    end
  end

  def get_envs
    begin
      content = File.read $env_file
    rescue Errno::ENOENT => e
      puts 'Could not find ENV file'
      exit 1
    end

    content.gsub! /\r\n?/, "\n"
    content.each_line do |line|
      # skip lines with no content
      next if line.gsub(/\s/, '').length === 0

      key, value = line.split '='
      $envs[key] = value.gsub! /\r|\n/, ''

      puts "Found ENV #{key}=#{value}" if $verbose
    end

    if $envs.length == 0
      puts 'Found no ENV variables in .env'
      exit
    end
  end

  def get_unused
    puts "Searching to find #{colorize($envs.length, 33)} ENV variables"

    $files.each do |file|
      content = File.read file

      content.each_line do |line|
        $envs.each do |key, value|
          if line =~ /ENV\[["|']#{key}["|']\]/i
            $used_envs[key] = value
          end
        end
      end
    end
  end
end

EnvPrune.new.call

